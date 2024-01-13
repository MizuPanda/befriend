const functions = require("firebase-functions");
const admin = require("firebase-admin");
const express = require('express')
const cors = require('cors');
const app = express();
var serviceAccount = require("./creds.json");


admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});


app.use(cors());


app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  next();
});

// url endpoint checks if username is available
// write links like so:
// https://us-central1-befriend-b14ca.cloudfunctions.net/app/checkUsernameAvailability?username=01juniel
//Node: link will be different. Will return either true or false
app.get('/checkUsernameAvailability',async(req,res)=>{
  
  const username= req.query.username;
  const snapshot = await admin.firestore().collection("users")
  .where("username", "==", username)
  .limit(1)
  .get();

  const isUsernameAvailable = snapshot.empty;

  res.send(isUsernameAvailable); 
});

//grabs all users 
app.get('/grabAllUsers',async(req,res)=>{
  let UserList = [];
  
  const snapshot = await admin.auth().listUsers()
  //console.log(snapshot["users"]);
  for (let element in snapshot["users"]){
    console.log(element)
    UserList.push(
      {
        "displayName": snapshot["users"][element]["displayName"],
        "uid": snapshot["users"][element]["uid"],
      }
      );
  }
  


  res.send({"users":UserList}); 
});




    exports.app = functions.https.onRequest(app);