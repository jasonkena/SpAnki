<div>
<script src="https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/8.10.0/firebase-firestore.js"></script>
</div>
const firebase = require("firebase");
// Required for side-effects
require("firebase/firestore");

firebase.initializeApp({
    apiKey: 'AIzaSyAwVEjv8bARcTuYOSwqVhr3U0lp680Rfe4',
    authDomain: 'spanki-ffa20.firebaseapp.com',
    projectId: 'spanki-ffa20'
  });
  
var db = firebase.firestore();

const db = getFirestore();
const cityRef = db.collection('users').doc('507CnFJFHUOe4BOMthxnVzwo5IG3').collection('docs').doc('NqJHg7s143EbXEqh1rJ3');

const res = await cityRef.update({word: "table"});