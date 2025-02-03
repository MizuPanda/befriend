const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {updateFriendships, setUserData} = require("../helpers/firestoreUtils");
const {movePictureToPermanentStorage, setPictureData, deletePicture} = require("../helpers/storageUtils");

exports.publishPicture = functions.https.onCall(async (data, context) => {
  const sessionUsers = data.sessionUsers;
  const timestamp = admin.firestore.Timestamp.fromMillis(data.timestamp);
  const caption = data.caption;
  const hostId = data.hostId;
  const imageUrl = data.imageUrl;
  const usersAllowed = data.usersAllowed;
  const metadata = data.metadata;
  const isPublic = data.isPublic;

  try {
    // 1. Update Friendships
    await updateFriendships(sessionUsers, timestamp);

    // 2. Upload Picture
    const permanentUrl = await movePictureToPermanentStorage(hostId, imageUrl);

    // 3. Set Picture Data
    await setPictureData(hostId, permanentUrl, timestamp, caption, sessionUsers, usersAllowed, metadata, isPublic);

    // 4. Set User Data
    await setUserData(sessionUsers, hostId, timestamp);

    return {result: "success"};
  } catch (error) {
    console.error("Error publishing picture: ", error);
    throw new functions.https.HttpsError("internal", "Error publishing picture.");
  }
});

exports.deletePictureForSessionUsers = functions.https.onCall(async (data, context) => {
  // Ensure the user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "The function must be called while authenticated.");
  }

  const {hostId, pictureId, downloadUrl} = data;

  if (!hostId || !pictureId || !downloadUrl) {
    throw new functions.https.HttpsError("invalid-argument", "The function must be called with both hostId, pictureId, and downloadUrl.");
  }

  try {
    // Directly use the helper function for deletion
    await deletePicture({hostId, pictureId, downloadUrl});

    return {success: true, message: "Picture deleted successfully for all session users."};
  } catch (error) {
    console.error("Error deleting picture for session users:", error);
    throw new functions.https.HttpsError("internal", "An error occurred while deleting the picture for session users.");
  }
});
