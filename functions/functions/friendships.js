const functions = require("firebase-functions");
const {firestore} = require("../helpers/firestoreUtils");
const {fetchFriendshipsForUser, updateUserRelationships} = require("../helpers/firestoreUtils");

exports.generateFriendshipMap = functions.https.onCall(async (data, context) => {
    // Ensure the user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }

    const sessionUsers = data.sessionUsers; // This should be an array of user IDs in the session
    const hostId = data.hostId; // Assuming this is passed in the data
    console.log("Session user is ", hostId);
    const friendshipMap = {};

    try {
        for (const userId of sessionUsers) {
            console.log("Processing user: ", userId);
            // Fetch friendships for the user
            const friendships = await fetchFriendshipsForUser(userId, sessionUsers);
            console.log("Found friendships: ", friendships);
            // Add to the map
            friendshipMap[userId] = friendships;
        }
            console.log("Final friendshipMap: ", friendshipMap);

        // Save the friendshipMap to the host"s document
        await firestore.collection("users").doc(hostId).update({
            hostingFriendships: friendshipMap,
        });

        return {success: true};
    } catch (error) {
        console.error("Error generating friendship map: ", error);
        throw new functions.https.HttpsError("internal", "Unable to generate friendship map.");
    }
});

exports.deleteFriendship = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "The function must be called while authenticated.");
  }

  const {userId, targetUserId, friendshipId} = data;
  if (!userId || !targetUserId || !friendshipId) {
    throw new functions.https.HttpsError("invalid-argument", "The function must be called with userId, targetUserId, and friendshipId.");
  }

  try {
    await updateUserRelationships({userId, targetUserId, friendshipId, action: "delete"});
    return {success: true, message: "Friendship deleted successfully."};
  } catch (error) {
    console.error("Error in deleteFriendship:", error);
    throw new functions.https.HttpsError("internal", "Unable to delete friendship.");
  }
});

exports.blockUser = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "The function must be called while authenticated.");
  }

  const {userId, targetUserId, friendshipId} = data;
  if (!userId || !targetUserId) {
    throw new functions.https.HttpsError("invalid-argument", "The function must be called with userId and targetUserId.");
  }

  try {
    await updateUserRelationships({userId, targetUserId, friendshipId, action: "block"});
    return {success: true, message: "User blocked successfully."};
  } catch (error) {
    console.error("Error in blockUser:", error);
    throw new functions.https.HttpsError("internal", "Unable to block user.");
  }
});
