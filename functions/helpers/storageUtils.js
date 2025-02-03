const functions = require("firebase-functions");
const admin = require("firebase-admin");
const storage = admin.storage();
const {firestore} = require("../helpers/firestoreUtils");
const {getDownloadURL} = require("firebase-admin/storage");

// What?
async function movePictureToPermanentStorage(hostId, tempDownloadUrl) {
  try {
    // Extract the file name from the temporary download URL
    const url = new URL(tempDownloadUrl);
    const filePath = decodeURIComponent(url.pathname);
    const fileName = filePath.split("/").pop();

    if (!fileName) {
      throw new Error("Invalid file name extracted from URL");
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
    throw new functions.https.HttpsError("internal", "Error moving picture to permanent storage");
  }
}

async function setPictureData(hostId, imageUrl, timestamp, caption, sessionUsers, usersAllowed, metadata, isPublic) {
  try {
    const pictureDoc = {
      hostId: hostId,
      fileUrl: imageUrl,
      timestamp: timestamp,
      metadata: metadata,
      caption: caption,
      allowed: usersAllowed,
      sessionUsers: sessionUsers,
      likes: [],
      firstLikes: [],
      isPublic: isPublic,
    };

    await firestore.collection("pictures").add(pictureDoc);
  } catch (error) {
    console.error("(setPictureData) Error setting picture data:", error);
    throw new functions.https.HttpsError("internal", "Error setting picture data");
  }
}

// Helper function to delete a picture and its references from session users
async function deletePicture({hostId, pictureId, downloadUrl}) {
  // Create an array to store the promises
    const deletePromises = [];

    // Delete the picture document from Firestore
    deletePromises.push(firestore.collection("pictures").doc(pictureId).delete());

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

module.exports = {
movePictureToPermanentStorage,
setPictureData,
deletePicture,
};
