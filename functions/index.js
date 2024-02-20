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