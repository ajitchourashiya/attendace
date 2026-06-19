importScripts(
  'https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js'
);

importScripts(
  'https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js'
);

firebase.initializeApp({
  apiKey: "AIzaSyCxgeqIZ1KxKdCTa2RQExK9LZMjBbD4XIU",
  authDomain: "demotp-46f3d.firebaseapp.com",
  projectId: "demotp-46f3d",
  messagingSenderId: "1042065447563",
  appId: "1:1042065447563:web:19c3601613a19f260f128e"
});

const messaging = firebase.messaging();