const admin = require("firebase-admin");
admin.initializeApp();

// Import all functions
const authFunctions = require("./functions/auth");
const notificationFunctions = require("./functions/notifications");
const pictureFunctions = require("./functions/pictures");
const friendshipFunctions = require("./functions/friendships");
const historyFunctions = require("./functions/histories");

// Export functions for Firebase
module.exports = {
  ...authFunctions,
  ...notificationFunctions,
  ...pictureFunctions,
  ...friendshipFunctions,
  ...historyFunctions,
};
