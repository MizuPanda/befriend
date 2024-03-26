const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const firestore = admin.firestore();
firestore.settings({
  ignoreUndefinedProperties: true,
});

exports.checkUsernameAvailability = functions.https
    .onCall(async (data, context) => {
      const username = data.username;

      // Check if the username already exists in Firestore
      const snapshot = await admin.firestore().collection("users")
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
        await admin.firestore().collection("users").doc(hostId).update({
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
                  username1: docData.username1,
                  username2: docData.username2,
                  level: docData.level,
                  progress: docData.progress,
                  lastSeen: docData.lastSeen
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
        throw new functions.https.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }

    const userIds = data.userIds; // Array of user IDs who can see the post
    const postCreatorName = data.postCreatorName; // Name of the user who created the post
    const hostId = data.hostId;

    // Loop through each userId and send a notification
    const promises = userIds.map(userId => {
        return admin.firestore().collection("users").doc(userId).get().then(doc => {
            if (!doc.exists) {
                console.log("No such user:", userId);
                return null;
            }
            const user = doc.data();
            const token = user.notificationToken; // Ensure you have stored the token as mentioned earlier

            if (token) {
                const message = {
                    notification: {
                        title: "New Post",
                        body: `${postCreatorName} has posted a new picture. Check it out!`,
                    },
                    token: token,
                    data: {
                        hostId: hostId,
                    }

                };

                return admin.messaging().send(message);
            } else {
                console.log("No notification token for user:", userId);
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
        throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
    }

    // Extract data passed from the client
    const likerUsername = data.likerUsername;
    const ownerId = data.ownerId;

    try {
        // Fetch the owner's notification token from Firestore
        const ownerDoc = await admin.firestore().collection('users').doc(ownerId).get();
        if (!ownerDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'Failed to find the post owner in Firestore.');
        }
        const ownerToken = ownerDoc.data().notificationToken;
        if (!ownerToken) {
            throw new functions.https.HttpsError('not-found', 'The post owner does not have a notification token.');
        }

        // Prepare the notification message
        const message = {
            notification: {
                title: 'Someone liked your post!',
                body: `${likerUsername} has liked your post!`,
            },
            token: ownerToken,
        };

        // Send the notification
        const response = await admin.messaging().send(message);
        console.log('Successfully sent message:', response);

        // Respond to the client indicating success
        return { result: `Message sent to ${ownerId} successfully.` };
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

   // Reference to the user's document
    const userDocRef = admin.firestore().collection('users').doc(uid);

    // First, fetch the user document to access the avatar field
    const userDoc = await userDocRef.get();
    if (!userDoc.exists) {
      console.log(`User document for UID: ${uid} does not exist.`);
    } else {
      // If the avatar field exists and contains a URL, delete the corresponding file in Storage
      const avatarUrl = userDoc.data().avatar;
      if (avatarUrl) {
        // Parse the avatarUrl to extract the file path
        const decodeURL = decodeURIComponent(avatarUrl);
        const pathMatch = decodeURL.match(/\/o\/(.+)\?alt=media/);
        if (pathMatch && pathMatch.length > 1) {
          const filePath = pathMatch[1];
          // Delete the file from Firebase Storage
          await admin.storage().bucket().file(filePath).delete();
        }
      }
    }

    // Delete the user's document
    await userDocRef.delete();

  // Get a reference for the sub collection.
  const picturesCollectionRef = userDocRef.collection('pictures');

  // Find and delete all pictures where the user is the host
  const picturesSnapshot = await picturesCollectionRef.where('hostId', '==', uid).get();
  for (const doc of picturesSnapshot.docs) {
      const pictureData = doc.data();
      await deletePicture({
          hostId: uid,
          pictureId: doc.id,
          downloadUrl: pictureData.downloadUrl
      });
  }

  // Delete the 'pictures' subcollection
  await deleteCollection(picturesCollectionRef);

  // Delete user's document from "User" collection
  await admin.firestore().collection('users').doc(uid).delete();

  // Delete the user's Firebase Authentication account
  try {
    await admin.auth().deleteUser(uid);
    console.log(`Successfully deleted Firebase Auth user for UID: ${uid}`);
  } catch (error) {
    console.error(`Error deleting Firebase Auth user for UID: ${uid}`, error);
  }

  // Remove user's UID from each friend's 'friends' array
  const friendPromises = friendIds.map(friendId =>
    admin.firestore().collection('users').doc(friendId).update({
      friends: admin.firestore.FieldValue.arrayRemove(uid)
    })
  );
  await Promise.all(friendPromises);

  // Delete all friendship documents
  const friendshipPromises = friendshipIds.map(friendshipId =>
    admin.firestore().collection('friendships').doc(friendshipId).delete()
  );
  await Promise.all(friendshipPromises);

  // Delete user's profile picture from "profile_pictures" folder
  const profilePicPath = `profile_pictures/${uid}.jpg`;
  await admin.storage().bucket().file(profilePicPath).delete().catch(error => console.log(error.message));

  // Delete all files in user's "session_pictures" folder
  // Note: As Firebase Admin SDK does not support direct folder deletion, list and delete each file.
  const sessionPicsPath = `session_pictures/${uid}/`;
  const files = await admin.storage().bucket().getFiles({ prefix: sessionPicsPath });
  const deletePromises = files[0].map(file => file.delete());
  await Promise.all(deletePromises).catch(error => console.log(error.message));

  console.log(`Successfully deleted all data for user: ${uid}`);
});

async function deleteCollection(collectionRef) {
  const snapshot = await collectionRef.get();
  const deletionPromises = [];
  snapshot.forEach(doc => {
    deletionPromises.push(doc.ref.delete());
  });
  await Promise.all(deletionPromises);
}

// Shared logic for modifying user relationships
async function updateUserRelationships({ userId, targetUserId, targetUsername, friendshipId, action }) {
  const userRef = admin.firestore().collection('users').doc(userId);
  const targetUserRef = admin.firestore().collection('users').doc(targetUserId);
  const friendshipRef = admin.firestore().collection('friendships').doc(friendshipId);

  await admin.firestore().runTransaction(async (transaction) => {
    // Remove targetUserId from the user's 'friends' array
    transaction.update(userRef, {
      friends: admin.firestore.FieldValue.arrayRemove(targetUserId)
    });
    transaction.update(targetUserRef, {
          friends: admin.firestore.FieldValue.arrayRemove(userId)
        });

    // Depending on the action, block the user
    if (action === 'block') {
      let updates = {};
      updates[`blocked.${targetUserId}`] = targetUsername; // Dynamically create the property path

      transaction.update(userRef, updates);
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

  const { userId, targetUserId, targetUsername, friendshipId } = data;
  if (!userId || !targetUserId || !targetUsername || !friendshipId) {
    throw new functions.https.HttpsError('invalid-argument', 'The function must be called with userId, targetUserId and friendshipId.');
  }

  try {
    await updateUserRelationships({ userId, targetUserId, targetUsername, friendshipId, action: 'delete' });
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

  const { userId, targetUserId, targetUsername, friendshipId } = data;
  if (!userId || !targetUserId || !targetUsername || !friendshipId) {
    throw new functions.https.HttpsError('invalid-argument', 'The function must be called with userId, targetUserId, friendshipId.');
  }

  try {
    await updateUserRelationships({ userId, targetUserId, targetUsername, friendshipId, action: 'block' });
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
  // Delete the picture from each session user's pictures subcollection
  const pictureDoc = await admin.firestore()
    .collection('users').doc(hostId)
    .collection('pictures').doc(pictureId)
    .get();

  if (!pictureDoc.exists) {
    console.log('Picture document does not exist:', pictureId);
    return;
  }

  const sessionUsers = pictureDoc.data().sessionUsers;
  if (!sessionUsers) {
    console.log('The sessionUsers field is missing in the picture document:', pictureId);
    return;
  }

  const deletePromises = Object.keys(sessionUsers).map(userId =>
    admin.firestore()
      .collection('users').doc(userId)
      .collection('pictures').doc(pictureId)
      .delete()
  );

  // Delete the file from Firebase Storage
  if (downloadUrl) {
    const decodeURL = decodeURIComponent(downloadUrl);
    const pathMatch = decodeURL.match(/\/o\/(.+)\?alt=media/);
    if (pathMatch && pathMatch.length > 1) {
      const filePath = pathMatch[1];
      deletePromises.push(admin.storage().bucket().file(filePath).delete());
    }
  }

  await Promise.all(deletePromises);
}
