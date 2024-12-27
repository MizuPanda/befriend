const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { getDownloadURL } = require('firebase-admin/storage');

admin.initializeApp();

const storage = admin.storage();
const firestore = admin.firestore();

firestore.settings({
  ignoreUndefinedProperties: true,
});

const localizedStrings = {
  en: require('./locales/en.json'),
  fr: require('./locales/fr.json'),
};

// Function to get localized string
function getLocalizedString(language, key) {
  return localizedStrings[language] ? localizedStrings[language][key] : localizedStrings['en'][key];
}

exports.checkUsernameAvailability = functions.https
    .onCall(async (data, context) => {
      const username = data.username;

      // Check if the username already exists in Firestore
      const snapshot = await firestore.collection("users")
          .where("username", "==", username)
          .limit(1)
          .get();

      const isUsernameAvailable = snapshot.empty;

      return {isUsernameAvailable};
    });

exports.generateFriendshipMap = functions.https.onCall(async (data, context) => {
    // Ensure the user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }

    const sessionUsers = data.sessionUsers; // This should be an array of user IDs in the session
    const hostId = data.hostId; // Assuming this is passed in the data
    console.log("Session user is ", hostId);
    let friendshipMap = {};

    try {
        for (let userId of sessionUsers) {
            console.log("Processing user: ", userId);
            // Fetch friendships for the user
            const friendships = await fetchFriendshipsForUser(userId, sessionUsers);
            console.log("Found friendships: ", friendships);
            // Add to the map
            friendshipMap[userId] = friendships;
        }
            console.log("Final friendshipMap: ", friendshipMap);

        // Save the friendshipMap to the host's document
        await firestore.collection("users").doc(hostId).update({
            hostingFriendships: friendshipMap
        });

        return { success: true };
    } catch (error) {
        console.error("Error generating friendship map: ", error);
        throw new functions.https.HttpsError("internal", "Unable to generate friendship map.");
    }
});

async function fetchFriendshipsForUser(userId, sessionUsers) {
    const friendships = [];

        // Attempt to simulate the OR condition by performing two queries and merging the results
        const query1 = firestore.collection('friendships').where('user1', '==', userId).get();
        const query2 = firestore.collection('friendships').where('user2', '==', userId).get();

        try {
            // Wait for both queries to complete
            const [querySnapshot1, querySnapshot2] = await Promise.all([query1, query2]);

            // Function to process each document
            const processDoc = (doc) => {
                // Manually create a progress object based on the document's data
                const docData = doc.data();
                const progress = {
                  user1: docData.user1,
                  user2: docData.user2,
                  level: docData.level,
                  progress: docData.progress,
                };

                // Assuming `sessionUserIds` contains the IDs of users in the session
                if (!(sessionUsers.includes(progress.user1) && sessionUsers.includes(progress.user2))) {
                    friendships.push(progress);
                }
            };

            // Process each document in the first query's results
            querySnapshot1.forEach(processDoc);

            // Process each document in the second query's results
            querySnapshot2.forEach(processDoc);

        } catch (error) {
            console.error("Error fetching friendships for user ${userId}:", error);
            throw error; // Re-throw the error to be caught by the caller
        }

        return friendships;
}

exports.sendNewPostNotification = functions.https.onCall((data, context) => {
    // Ensure the user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
    }

    const userIds = data.userIds; // Array of user IDs who can see the post
    const postCreatorName = data.postCreatorName; // Name of the user who created the post
    const hostId = data.hostId;

    // Loop through each userId and send a notification
    const promises = userIds.map(userId => {
        return firestore.collection('users').doc(userId).get().then(doc => {
            if (!doc.exists) {
                console.log('No such user:', userId);
                return null;
            }
            const user = doc.data();
            const token = user.notificationToken; // Ensure you have stored the token as mentioned earlier
            const postNotificationOn = user.postNotificationOn;
            const languageCode = user.language || 'en';

            // Get localized message
            const title = getLocalizedString(languageCode, 'postTitle');
            const body = `${postCreatorName} ${getLocalizedString(languageCode, 'postDescription')}`;

            if (token && postNotificationOn) {
                const message = {
                    notification: {
                        title: title,
                        body: body,
                    },
                    token: token,
                    data: {
                        hostId: hostId,
                    }
                };

                return admin.messaging().send(message);
            } else {
                console.log('No notification token for user:', userId);
                return null;
            }
        });
    });

    return Promise.all(promises).then(results => {
        console.log('Notifications sent:', results);
        return { success: true, message: 'Notifications sent' };
    }).catch(error => {
        console.error('Error sending notifications:', error);
        throw new functions.https.HttpsError('internal', 'Error sending notifications');
    });
});

exports.sendPostLikeNotification = functions.https.onCall(async (data, context) => {
    // Ensure the user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
    }

    // Extract data passed from the client
    const likerUsername = data.likerUsername;
    const sessionUsers = data.sessionUsers;

    try {
        for (let sessionUser of sessionUsers) {
            // Fetch the owner's notification token from Firestore
            const sessionUserDoc = await firestore.collection('users').doc(sessionUser).get();
            if (!sessionUserDoc.exists) {
                throw new functions.https.HttpsError('not-found', 'Failed to find the post owner in Firestore.');
            }

            const userData = sessionUserDoc.data();
            const sessionUserToken = userData.notificationToken;
            const sessionUserLanguage = userData.language || 'en';
            const sessionUserLikeNotificationOn = userData.likeNotificationOn;

            if (!sessionUserToken) {
                throw new functions.https.HttpsError('not-found', 'The post owner does not have a notification token.');
            }

            // Get localized message
            const title = getLocalizedString(sessionUserLanguage, 'likeTitle');
            const body = `${likerUsername} ${getLocalizedString(sessionUserLanguage, 'likeDescription')}`;

            // Prepare the notification message
            const message = {
                notification: {
                    title: title,
                    body: body,
                },
                token: sessionUserToken,
            };

            if (sessionUserLikeNotificationOn) {
                // Send the notification
                const response = await admin.messaging().send(message);
                console.log('Successfully sent message:', response);
            }
        }

        // Respond to the client indicating success
        return { result: 'Message sent successfully.' };
    } catch (error) {
        console.log('Error sending message:', error);
        throw new functions.https.HttpsError('unknown', 'Failed to send notification.', error);
    }
});

exports.deleteUserData = functions.https.onCall(async (data, context) => {
  // Ensure the user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  const uid = data.uid;
  const friendshipIds = data.friendshipIds;
  const friendIds = data.friendIds;

  try {
    // Reference to the user's document
    const userDocRef = firestore.collection('users').doc(uid);

    // Delete the user's document
    await userDocRef.delete();

    // Get a reference for the picture collection.
    const picturesCollectionRef = firestore.collection('pictures');

    // Find and delete all pictures where the user is the host
    const picturesSnapshot = await picturesCollectionRef.where('hostId', '==', uid).get();
    for (const doc of picturesSnapshot.docs) {
      const pictureData = doc.data();
      await deletePicture({
        hostId: uid,
        pictureId: doc.id,
        downloadUrl: pictureData.downloadUrl,
      });
    }

    // Delete the user's Firebase Authentication account
    try {
      await admin.auth().deleteUser(uid);
      console.log(`Successfully deleted Firebase Auth user for UID: ${uid}`);
    } catch (error) {
      console.error(`Error deleting Firebase Auth user for UID: ${uid}`, error);
    }

    // Remove user's UID from each friend's 'friends' array
    const friendPromises = friendIds.map((friendId) =>
      firestore.collection('users').doc(friendId).update({
        friends: admin.firestore.FieldValue.arrayRemove(uid),
      })
    );
    await Promise.all(friendPromises);

    // Delete all friendship documents
    const friendshipPromises = friendshipIds.map((friendshipId) =>
      firestore.collection('friendships').doc(friendshipId).delete()
    );
    await Promise.all(friendshipPromises);

    // Delete user's profile picture from "profile_pictures" folder
    const profilePicPath = `profile_pictures/${uid}.jpg`;
    try {
      await storage.bucket().file(profilePicPath).delete();
    } catch (error) {
      console.error(`Error deleting profile picture for UID: ${uid}`, error);
    }

    // Delete all files in user's "session_pictures" folder
    // Note: As Firebase Admin SDK does not support direct folder deletion, list and delete each file.
    const sessionTempPics = `session_pictures/${uid}/temp/`;
    try {
      const [files] = await storage.bucket().getFiles({ prefix: sessionTempPics });
      const deletePromises = files.map((file) => file.delete());
      await Promise.all(deletePromises);
    } catch (error) {
      console.error(`Error deleting session pictures for UID: ${uid}`, error);
    }

    console.log(`Successfully deleted all data for user: ${uid}`);
  } catch (error) {
    console.error(`Error deleting user data for UID: ${uid}`, error);
    throw new functions.https.HttpsError('unknown', 'Error deleting user data.');
  }
});

// Shared logic for modifying user relationships
async function updateUserRelationships({ userId, targetUserId, friendshipId, action }) {
  const userRef = firestore.collection('users').doc(userId);
  const targetUserRef = firestore.collection('users').doc(targetUserId);
  const friendshipRef = firestore.collection('friendships').doc(friendshipId);

  await firestore.runTransaction(async (transaction) => {
    // Remove targetUserId from the user's 'friends' array
    transaction.update(userRef, {
      friends: admin.firestore.FieldValue.arrayRemove(targetUserId)
    });
    transaction.update(targetUserRef, {
          friends: admin.firestore.FieldValue.arrayRemove(userId)
        });

    // Depending on the action, block the user
    if (action === 'block') {
      transaction.update(userRef, {
            blocked: admin.firestore.FieldValue.arrayUnion(targetUserId)
          });
    }

    // Delete the friendship document
    transaction.delete(friendshipRef);
  });
}

// Function to handle friendship deletion
exports.deleteFriendship = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
  }

  const { userId, targetUserId, friendshipId } = data;
  if (!userId || !targetUserId || !friendshipId) {
    throw new functions.https.HttpsError('invalid-argument', 'The function must be called with userId, targetUserId and friendshipId.');
  }

  try {
    await updateUserRelationships({ userId, targetUserId, friendshipId, action: 'delete' });
    return { success: true, message: 'Friendship deleted successfully.' };
  } catch (error) {
    console.error('Error in deleteFriendship:', error);
    throw new functions.https.HttpsError('internal', 'Unable to delete friendship.');
  }
});

// Function to handle user blocking
exports.blockUser = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
  }

  const { userId, targetUserId, friendshipId } = data;
  if (!userId || !targetUserId || !friendshipId) {
    throw new functions.https.HttpsError('invalid-argument', 'The function must be called with userId, targetUserId, friendshipId.');
  }

  try {
    await updateUserRelationships({ userId, targetUserId, friendshipId, action: 'block' });
    return { success: true, message: 'User blocked successfully.' };
  } catch (error) {
    console.error('Error in blockUser:', error);
    throw new functions.https.HttpsError('internal', 'Unable to block user.');
  }
});

exports.deletePictureForSessionUsers = functions.https.onCall(async (data, context) => {
  // Ensure the user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
  }

  const { hostId, pictureId, downloadUrl } = data;

  if (!hostId || !pictureId || !downloadUrl) {
    throw new functions.https.HttpsError('invalid-argument', 'The function must be called with both hostId, pictureId, and downloadUrl.');
  }

  try {
    // Directly use the helper function for deletion
    await deletePicture({ hostId, pictureId, downloadUrl });

    return { success: true, message: 'Picture deleted successfully for all session users.' };
  } catch (error) {
    console.error('Error deleting picture for session users:', error);
    throw new functions.https.HttpsError('internal', 'An error occurred while deleting the picture for session users.');
  }
});

// Helper function to delete a picture and its references from session users
async function deletePicture({hostId, pictureId, downloadUrl}) {
  // Create an array to store the promises
    const deletePromises = [];

    // Delete the picture document from Firestore
    deletePromises.push(firestore.collection('pictures').doc(pictureId).delete());

    // Delete the file from Firebase Storage if downloadUrl is provided
    if (downloadUrl) {
      const decodeURL = decodeURIComponent(downloadUrl);
      const pathMatch = decodeURL.match(/\/o\/(.+)\?alt=media/);
      if (pathMatch && pathMatch.length > 1) {
        const filePath = pathMatch[1];
        deletePromises.push(storage.bucket().file(filePath).delete());
      }
    }

    // Wait for all delete operations to complete
    await Promise.all(deletePromises);
}

exports.publishPicture = functions.https.onCall(async (data, context) => {
  const sessionUsers = data.sessionUsers;
  const timestamp = admin.firestore.Timestamp.fromMillis(data.timestamp);
  const caption = data.caption;
  const hostId = data.hostId;
  const imageUrl = data.imageUrl;
  const userMap = data.userMap;
  const usersAllowed = data.usersAllowed;
  const metadata = data.metadata;
  const isPublic = data.isPublic;

  try {
    // 1. Update Friendships
    await updateFriendships(sessionUsers, userMap, timestamp);

    // 2. Upload Picture
    const permanentUrl = await movePictureToPermanentStorage(hostId, imageUrl);

    // 3. Set Picture Data
    await setPictureData(hostId, permanentUrl, timestamp, caption, userMap, usersAllowed, metadata, isPublic);

    // 4. Set User Data
    await setUserData(sessionUsers, hostId, timestamp);

    return { result: 'success' };
  } catch (error) {
    console.error("Error publishing picture: ", error);
    throw new functions.https.HttpsError('internal', 'Error publishing picture.');
  }
});

async function updateFriendships(sessionUsers, userMap, timestamp) {
  for (let i = 0; i < sessionUsers.length; i++) {
    for (let j = i + 1; j < sessionUsers.length; j++) {
      const userID1 = sessionUsers[i];
      const userID2 = sessionUsers[j];

      // Skip if one user is blocking the other
      const [userDoc1, userDoc2] = await Promise.all([
        firestore.collection('users').doc(userID1).get(),
        firestore.collection('users').doc(userID2).get(),
      ]);

      if (!userDoc1.exists || !userDoc2.exists) continue;

      const user1Data = userDoc1.data();
      const user2Data = userDoc2.data();

      if (!user1Data || !user2Data) continue;

      const user1Blocked = user1Data.blocked?.hasOwnProperty(userID2);
      const user2Blocked = user2Data.blocked?.hasOwnProperty(userID1);

      if (user1Blocked || user2Blocked) continue;

      // Ensure the IDs are in alphabetical order for the document ID
      const ids = [userID1, userID2].sort();
      const friendshipDocId = ids.join('');

      const friendshipDoc = await firestore.collection('friendships').doc(friendshipDocId).get();

      if (friendshipDoc.exists) {
        // Update existing friendship
        const data = friendshipDoc.data();
        let progress = data?.progress || 0;
        progress += 0.2;

        if (progress >= 1) {
           await firestore.collection('friendships').doc(friendshipDocId).update({
             progress: progress - 1,
             level: admin.firestore.FieldValue.increment(1),
           });

           await Promise.all([
              firestore.collection('users').doc(userID1).update({
                power: admin.firestore.FieldValue.increment(1),
              }),
              firestore.collection('users').doc(userID2).update({
                power: admin.firestore.FieldValue.increment(1),
              }),
           ]);
        } else {
            await firestore.collection('friendships').doc(friendshipDocId).update({
              progress: progress,
            });
        }
      } else {
        await firestore.collection('friendships').doc(friendshipDocId).set({
          user1: ids[0],
          user2: ids[1],
          friendshipId: friendshipDocId,
          level: 1,
          progress: 0.2,
          created: timestamp,
        });

        await Promise.all([
          firestore.collection('users').doc(userID1).update({
            friends: admin.firestore.FieldValue.arrayUnion(userID2),
          }),
          firestore.collection('users').doc(userID2).update({
            friends: admin.firestore.FieldValue.arrayUnion(userID1),
          }),
        ]);
      }
    }
  }
}

async function movePictureToPermanentStorage(hostId, tempDownloadUrl) {
  try {
    // Extract the file name from the temporary download URL
    const url = new URL(tempDownloadUrl);
    const filePath = decodeURIComponent(url.pathname);
    const fileName = filePath.split('/').pop();

    if (!fileName) {
      throw new Error('Invalid file name extracted from URL');
    }

    console.log(`(movePictureToPermanentStorage): File name = ${fileName}`);

    // Define the temporary and permanent file paths
    const tempFilePath = `session_pictures/${hostId}/temp/${fileName}`;
    const permFilePath = `session_pictures/${hostId}/posted/${fileName}`;

    // Move the file from the temp path to the permanent path
    await storage.bucket().file(tempFilePath).move(permFilePath);

    // Generate a non-expiring download URL for the file
    const fileRef = storage.bucket().file(permFilePath);
    const downloadURL = await getDownloadURL(fileRef);

    console.log(`(movePictureToPermanentStorage): Permanent URL = ${downloadURL}`);

    return downloadURL;
  } catch (error) {
    console.error("Error moving picture to permanent storage:", error);
    throw new functions.https.HttpsError('internal', 'Error moving picture to permanent storage');
  }
}

async function setPictureData(hostId, imageUrl, timestamp, caption, userMap, usersAllowed, metadata, isPublic) {
  try {
    const pictureDoc = {
      hostId: hostId,
      fileUrl: imageUrl,
      timestamp: timestamp,
      metadata: metadata,
      caption: caption,
      allowed: usersAllowed,
      sessionUsers: userMap,
      likes: [],
      firstLikes: [],
      isPublic: isPublic,
    };

    await firestore.collection('pictures').add(pictureDoc);
  } catch (error) {
    console.error("(setPictureData) Error setting picture data:", error);
    throw new functions.https.HttpsError('internal', 'Error setting picture data');
  }
}

async function setUserData(sessionUsers, hostId, timestamp) {
  try {
    const lst = ['publishing', ...sessionUsers];

    for (const userId of sessionUsers) {
      const userDoc = await firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) continue;

      const lastSeenUsersMap = userDoc.data()?.lastSeenUsersMap || {};

      // Update lastSeenUsersMap for each user
      for (const otherUserId of sessionUsers) {
        if (otherUserId !== userId) {
          lastSeenUsersMap[otherUserId] = timestamp;
        }
      }

      if (userId === hostId) {
        console.log('(SessionProvider) Resetting Host Data');
        // Set host specific data and delete temporary pictures
        await firestore.collection('users').doc(userId).update({
          hosting: lst,
          hostingFriendships: {},
          lastSeenUsersMap: lastSeenUsersMap,
          caption: ''
        });

        await deleteTemporaryPictures(hostId);
      } else {
        await firestore.collection('users').doc(userId).update({
          lastSeenUsersMap: lastSeenUsersMap
        });
      }
    }
  } catch (error) {
    console.error("(setUserData): Error setting user data:", error);
    throw new functions.https.HttpsError('internal', 'Error setting user data');
  }
}

async function deleteTemporaryPictures(hostId) {
  try {
    // Get reference to the bucket
    const bucket = storage.bucket();

    // List all items (files) within the temp directory
    const [files] = await bucket.getFiles({ prefix: `session_pictures/${hostId}/temp/` });

    for (const file of files) {
      await file.delete(); // Delete each item
      console.log(`(PictureQuery): Deleting ${file.name}`);
    }
  } catch (error) {
    console.error("(deleteTemporaryPictures): Error deleting temporary pictures:", error);
    throw new functions.https.HttpsError('internal', 'Error deleting temporary pictures');
  }
}

exports.deleteUserSearchHistory = functions.https.onCall(async (data, context) => {
    // Check if the user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'You must be authenticated to call this function.'
        );
    }

    const userId = data.userId;

    // Validate the userId parameter
    if (!userId || typeof userId !== 'string') {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'The function must be called with a valid "userId" parameter.'
        );
    }

    try {
        const searchHistoryRef = firestore.collection('searchHistory');
        const snapshot = await searchHistoryRef.where('userId', '==', userId).get();

        if (snapshot.empty) {
            console.log(`No search history found for userId: ${userId}`);
            return { success: true, message: 'No search history to delete.' };
        }

        // Batch delete for efficiency
        const batch = firestore.batch();

        snapshot.docs.forEach((doc) => {
            batch.delete(doc.ref);
        });

        await batch.commit();

        console.log(`Successfully deleted search history for userId: ${userId}`);
        return { success: true, message: 'Search history successfully deleted.' };
    } catch (error) {
        console.error('Error deleting search history:', error);
        throw new functions.https.HttpsError(
            'internal',
            'An error occurred while deleting the search history.'
        );
    }
});