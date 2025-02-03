const admin = require("firebase-admin");
const functions = require("firebase-functions");
const firestore = admin.firestore();
const storage = admin.storage();

firestore.settings({
  ignoreUndefinedProperties: true,
});

async function fetchFriendshipsForUser(userId, sessionUsers) {
    const friendships = [];

        // Attempt to simulate the OR condition by performing two queries and merging the results
        const query1 = firestore.collection("friendships").where("user1", "==", userId).get();
        const query2 = firestore.collection("friendships").where("user2", "==", userId).get();

        try {
            // Wait for both queries to complete
            const [querySnapshot1, querySnapshot2] = await Promise.all([query1, query2]);

            // Function to process each document
            const processDoc = (doc) => {
                // Manually create a progress object based on the document"s data
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

// Shared logic for modifying user relationships
async function updateUserRelationships({userId, targetUserId, friendshipId, action}) {
  const userRef = firestore.collection("users").doc(userId);
  const targetUserRef = firestore.collection("users").doc(targetUserId);
  const friendshipRef = firestore.collection("friendships").doc(friendshipId);

  await firestore.runTransaction(async (transaction) => {
    // Remove targetUserId from the user"s "friends" array if they are friends
    transaction.update(userRef, {
      friends: admin.firestore.FieldValue.arrayRemove(targetUserId),
    });
    transaction.update(targetUserRef, {
      friends: admin.firestore.FieldValue.arrayRemove(userId),
    });

    // Handle blocking
    if (action === "block") {
      transaction.update(userRef, {
        blocked: admin.firestore.FieldValue.arrayUnion(targetUserId),
      });
    }

    // Delete the friendship document only if it exists and friendshipId is provided
    if (friendshipId) {
      const friendshipSnapshot = await transaction.get(friendshipRef);
      if (friendshipSnapshot.exists) {
        transaction.delete(friendshipRef);
      }
    }
  });
}

async function updateFriendships(sessionUsers, timestamp) {
  for (let i = 0; i < sessionUsers.length; i++) {
    for (let j = i + 1; j < sessionUsers.length; j++) {
      const userID1 = sessionUsers[i];
      const userID2 = sessionUsers[j];

      // Skip if one user is blocking the other
      const [userDoc1, userDoc2] = await Promise.all([
        firestore.collection("users").doc(userID1).get(),
        firestore.collection("users").doc(userID2).get(),
      ]);

      if (!userDoc1.exists || !userDoc2.exists) continue;

      const user1Data = userDoc1.data();
      const user2Data = userDoc2.data();

      if (!user1Data || !user2Data) continue;

      const user1Blocked = user1Data.blocked?.includes(userID2) || false;
      const user2Blocked = user2Data.blocked?.includes(userID1) || false;

      if (user1Blocked || user2Blocked) continue;

      // Ensure the IDs are in alphabetical order for the document ID
      const ids = [userID1, userID2].sort();
      const friendshipDocId = ids.join("");

      const friendshipDoc = await firestore.collection("friendships").doc(friendshipDocId).get();
      const streak1 = user1Data?.streak || 0;
      const streak2 = user2Data?.streak || 0;

      const global = (globalMultiplier(streak1) + globalMultiplier(streak2))/2;

      if (friendshipDoc.exists) {
        // Update existing friendship
        const data = friendshipDoc.data();

        // Convert the timestamp to a Date object
        const now = timestamp.toDate();

        // Use optional chaining to safely convert lastInteraction if it exists,
        // otherwise default to now.
        const lastInteraction = data?.lastInteraction?.toDate() || now;

        // Calculate yesterday's date based on now
        const yesterday = new Date(now);
        yesterday.setDate(yesterday.getDate() - 1);

        // Compare only the date parts (year, month, day)
        const isFromYesterday = (
          lastInteraction.getFullYear() === yesterday.getFullYear() &&
          lastInteraction.getMonth() === yesterday.getMonth() &&
          lastInteraction.getDate() === yesterday.getDate()
        );

        const isFromToday = (
            lastInteraction.getFullYear() === now.getFullYear() &&
            lastInteraction.getMonth() === now.getMonth() &&
            lastInteraction.getDate() === now.getDate()
        );

        let progress = data?.progress || 0;

        const friendshipStreak = data?.streak || 0;
        const multiplier = 1*global*friendMultiplier(friendshipStreak);

        progress += 0.2*multiplier;

        if (progress >= 1) {
           await firestore.collection("friendships").doc(friendshipDocId).update({
             progress: progress - 1,
             level: admin.firestore.FieldValue.increment(1),
             lastInteraction: timestamp,
             streak: isFromYesterday? admin.firestore.FieldValue.increment(1) :
                                     (isFromToday? (friendshipStreak != 0? friendshipStreak : 1) : 1),
           });

           await Promise.all([
              firestore.collection("users").doc(userID1).update({
                power: admin.firestore.FieldValue.increment(1),
              }),
              firestore.collection("users").doc(userID2).update({
                power: admin.firestore.FieldValue.increment(1),
              }),
           ]);
        } else {
            await firestore.collection("friendships").doc(friendshipDocId).update({
              progress: progress,
              lastInteraction: timestamp,
              streak: isFromYesterday? admin.firestore.FieldValue.increment(1) :
                                      (isFromToday? (friendshipStreak != 0? friendshipStreak : 1) : 1),
            });
        }
      } else {
        await firestore.collection("friendships").doc(friendshipDocId).set({
          user1: ids[0],
          user2: ids[1],
          friendshipId: friendshipDocId,
          level: 1,
          progress: 0.2,
          created: timestamp,
          streak: 1,
          lastInteraction: timestamp,
        });

        await Promise.all([
          firestore.collection("users").doc(userID1).update({
            friends: admin.firestore.FieldValue.arrayUnion(userID2),
          }),
          firestore.collection("users").doc(userID2).update({
            friends: admin.firestore.FieldValue.arrayUnion(userID1),
          }),
        ]);
      }
    }
  }
}

function friendMultiplier(streak) {
  if (streak === 1) {
    return 1.1;
  } else if (streak > 1 && streak <= 4) {
    return 1.2;
  } else if (streak > 4 && streak <= 9) {
    return 1.5;
  } else if (streak > 9) {
    return 2.0;
  }

  return 1.0;
}

function globalMultiplier(streak) {
  if (streak > 0 && streak <= 2) {
    return 1.0 + (0.05 / (2 - 0)) * streak; // Range 1-2 | max at 1.05
  } else if (streak > 2 && streak <= 6) {
    return 1.05 + (0.05 / (6 - 2)) * (streak - 2); // Range 3-6 | max at 1.1
  } else if (streak > 6 && streak <= 14) {
    return 1.1 + (0.15 / (14 - 6)) * (streak - 6); // Range 7-14 | max at 1.25
  } else if (streak > 14) {
    return 1.5 + (streak - 15) * 0.005; // Range 15+ | no max
  }

  return 1.0;
}

async function setUserData(sessionUsers, hostId, timestamp) {
  try {
    const lst = ["publishing", ...sessionUsers];

    for (const userId of sessionUsers) {
      const userDoc = await firestore.collection("users").doc(userId).get();
      if (!userDoc.exists) continue;

      const lastSeenUsersMap = userDoc.data()?.lastSeenUsersMap || {};

      // Update lastSeenUsersMap for each user
      for (const otherUserId of sessionUsers) {
        if (otherUserId !== userId) {
          lastSeenUsersMap[otherUserId] = timestamp;
        }
      }

      // Get the current date and calculate yesterday's date
      // Convert the string to a Date object
      const now = timestamp.toDate();

      if (isNaN(now.getTime())) {
         throw new functions.https.HttpsError("invalid-argument", "Invalid date format.");
      }

      const lastInteraction = userDoc.data()?.lastInteraction?.toDate() || now;

      const yesterday = new Date(now);
      yesterday.setDate(yesterday.getDate() - 1);

      // Compare the date parts only
      const isFromYesterday = (
        lastInteraction.getFullYear() === yesterday.getFullYear() &&
        lastInteraction.getMonth() === yesterday.getMonth() &&
        lastInteraction.getDate() === yesterday.getDate()
      );

      const isFromToday = (
        lastInteraction.getFullYear() === now.getFullYear() &&
        lastInteraction.getMonth() === now.getMonth() &&
        lastInteraction.getDate() === now.getDate()
      );

      const userStreak = userDoc.data()?.streak || 1;

      if (userId === hostId) {
        console.log("(SessionProvider) Resetting Host Data");
        // Set host specific data and delete temporary pictures
        await firestore.collection("users").doc(userId).update({
          hosting: lst,
          hostingFriendships: {},
          lastSeenUsersMap: lastSeenUsersMap,
          caption: "",
          lastInteraction: timestamp,
          streak: isFromYesterday? admin.firestore.FieldValue.increment(1) :
                (isFromToday? (userStreak != 0? userStreak : 1) : 1),
        });

        await deleteTemporaryPictures(hostId);
      } else {
        await firestore.collection("users").doc(userId).update({
          lastSeenUsersMap: lastSeenUsersMap,
          lastInteraction: timestamp,
          streak: isFromYesterday? admin.firestore.FieldValue.increment(1) : 1,
        });
      }
    }
  } catch (error) {
    console.error("(setUserData): Error setting user data:", error);
    throw new functions.https.HttpsError("internal", "Error setting user data");
  }
}

async function deleteTemporaryPictures(hostId) {
  try {
    // Get reference to the bucket
    const bucket = storage.bucket();

    // List all items (files) within the temp directory
    const [files] = await bucket.getFiles({prefix: `session_pictures/${hostId}/temp/`});

    for (const file of files) {
      await file.delete(); // Delete each item
      console.log(`(PictureQuery): Deleting ${file.name}`);
    }
  } catch (error) {
    console.error("(deleteTemporaryPictures): Error deleting temporary pictures:", error);
    throw new functions.https.HttpsError("internal", "Error deleting temporary pictures");
  }
}

module.exports = {
firestore,
storage,
fetchFriendshipsForUser,
updateUserRelationships,
updateFriendships,
setUserData,
};
