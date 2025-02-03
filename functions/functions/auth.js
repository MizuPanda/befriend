const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {firestore, storage} = require("../helpers/firestoreUtils");
const {deletePicture} = require("../helpers/storageUtils");

exports.deleteUserData = functions.https.onCall(async (data, context) => {
  // Ensure the user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError("failed-precondition",
      "The function must be called while authenticated.");
  }

    const uid = data.uid;
    const friendshipIds = data.friendshipIds;
    const friendIds = data.friendIds;

    try {
      // Reference to the user"s document
      const userDocRef = firestore.collection("users").doc(uid);

      // Delete the user"s document
      await userDocRef.delete();

      // Get a reference for the picture collection.
      const picturesCollectionRef = firestore.collection("pictures");

      // Find and delete all pictures where the user is the host
      const picturesSnapshot = await picturesCollectionRef.where("hostId", "==", uid).get();
      for (const doc of picturesSnapshot.docs) {
        const pictureData = doc.data();
        await deletePicture({
          hostId: uid,
          pictureId: doc.id,
          downloadUrl: pictureData.downloadUrl,
        });
      }

      // Delete the user"s Firebase Authentication account
      try {
        await admin.auth().deleteUser(uid);
        console.log(`Successfully deleted Firebase Auth user for UID: ${uid}`);
      } catch (error) {
        console.error(`Error deleting Firebase Auth user for UID: ${uid}`, error);
      }

      // Remove user"s UID from each friend"s "friends" array
      const friendPromises = friendIds.map((friendId) =>
        firestore.collection("users").doc(friendId).update({
          friends: admin.firestore.FieldValue.arrayRemove(uid),
        }),
      );
      await Promise.all(friendPromises);

      // Delete all friendship documents
      const friendshipPromises = friendshipIds.map((friendshipId) =>
        firestore.collection("friendships").doc(friendshipId).delete(),
      );
      await Promise.all(friendshipPromises);

      // Delete user"s profile picture from "profile_pictures" folder
      const profilePicPath = `profile_pictures/${uid}.jpg`;
      try {
        await storage.bucket().file(profilePicPath).delete();
      } catch (error) {
        console.error(`Error deleting profile picture for UID: ${uid}`, error);
      }

      // Delete all files in user"s "session_pictures" folder
      // Note: As Firebase Admin SDK does not support direct folder deletion, list and delete each file.
      const sessionTempPics = `session_pictures/${uid}/temp/`;
      try {
        const [files] = await storage.bucket().getFiles({prefix: sessionTempPics});
        const deletePromises = files.map((file) => file.delete());
        await Promise.all(deletePromises);
      } catch (error) {
        console.error(`Error deleting session pictures for UID: ${uid}`, error);
      }

      console.log(`Successfully deleted all data for user: ${uid}`);
    } catch (error) {
      console.error(`Error deleting user data for UID: ${uid}`, error);
      throw new functions.https.HttpsError("unknown", "Error deleting user data.");
    }
});

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

