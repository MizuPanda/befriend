const functions = require("firebase-functions");
const {firestore} = require("../helpers/firestoreUtils");

exports.deleteUserSearchHistory = functions.https.onCall(async (data, context) => {
    // Check if the user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "You must be authenticated to call this function.",
        );
    }

    const userId = data.userId;

    // Validate the userId parameter
    if (!userId || typeof userId !== "string") {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "The function must be called with a valid 'userId' parameter.",
        );
    }

    try {
        const searchHistoryRef = firestore.collection("searchHistory");
        const snapshot = await searchHistoryRef.where("userId", "==", userId).get();

        if (snapshot.empty) {
            console.log(`No search history found for userId: ${userId}`);
            return {success: true, message: "No search history to delete."};
        }

        // Batch delete for efficiency
        const batch = firestore.batch();

        snapshot.docs.forEach((doc) => {
            batch.delete(doc.ref);
        });

        await batch.commit();

        console.log(`Successfully deleted search history for userId: ${userId}`);
        return {success: true, message: "Search history successfully deleted."};
    } catch (error) {
        console.error("Error deleting search history:", error);
        throw new functions.https.HttpsError(
            "internal",
            "An error occurred while deleting the search history.",
        );
    }
});
