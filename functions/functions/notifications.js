const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {firestore} = require("../helpers/firestoreUtils");
const {getLocalizedString} = require("../helpers/localization");

exports.sendNewPostNotification = functions.https.onCall(async (data, context) => {
    // Ensure the user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }

    const userIds = data.userIds; // Array of user IDs who can see the post
    const postCreatorName = data.postCreatorName; // Name of the user who created the post
    const hostId = data.hostId;

    // Loop through each userId and send a notification
    const promises = userIds.map((userId) => {
        return firestore.collection("users").doc(userId).get().then((doc) => {
            if (!doc.exists) {
                console.log("No such user:", userId);
                return null;
            }
            const user = doc.data();
            const token = user.notificationToken; // Ensure you have stored the token as mentioned earlier
            const postNotificationOn = user.postNotificationOn;
            const languageCode = user.language || "en";

            // Get localized message
            const title = getLocalizedString(languageCode, "postTitle");
            const body = `${postCreatorName} ${getLocalizedString(languageCode, "postDescription")}`;

            if (token && postNotificationOn) {
                const message = {
                    notification: {
                        title: title,
                        body: body,
                    },
                    token: token,
                    data: {
                        hostId: hostId,
                    },
                };

                return admin.messaging().send(message);
            } else {
                console.log("No notification token for user:", userId);
                return null;
            }
        });
    });

    return Promise.all(promises).then((results) => {
        console.log("Notifications sent:", results);
        return {success: true, message: "Notifications sent"};
    }).catch((error) => {
        console.error("Error sending notifications:", error);
        throw new functions.https.HttpsError("internal", "Error sending notifications");
    });
});

exports.sendPostLikeNotification = functions.https.onCall(async (data, context) => {
    // Ensure the user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }

    // Extract data passed from the client
    const likerUsername = data.likerUsername;
    const sessionUsers = data.sessionUsers;

    try {
        for (const sessionUser of sessionUsers) {
            // Fetch the owner"s notification token from Firestore
            const sessionUserDoc = await firestore.collection("users").doc(sessionUser).get();
            if (!sessionUserDoc.exists) {
                throw new functions.https.HttpsError("not-found", "Failed to find the post owner in Firestore.");
            }

            const userData = sessionUserDoc.data();
            const sessionUserToken = userData.notificationToken;
            const sessionUserLanguage = userData.language || "en";
            const sessionUserLikeNotificationOn = userData.likeNotificationOn;

            if (!sessionUserToken) {
                throw new functions.https.HttpsError("not-found", "The post owner does not have a notification token.");
            }

            // Get localized message
            const title = getLocalizedString(sessionUserLanguage, "likeTitle");
            const body = `${likerUsername} ${getLocalizedString(sessionUserLanguage, "likeDescription")}`;

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
                console.log("Successfully sent message:", response);
            }
        }

        // Respond to the client indicating success
        return {result: "Message sent successfully."};
    } catch (error) {
        console.log("Error sending message:", error);
        throw new functions.https.HttpsError("unknown", "Failed to send notification.", error);
    }
});
