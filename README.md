# flutter_application_1

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

-------------------------------------------------------------------------------------------------------

For flutter auth in `index.html`:
```
<!-- The core Firebase JS SDK is always required and must be listed first -->
<script src="https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/8.6.1/firebase-auth.js"></script>

<script>
  // Your web app's Firebase configuration
  // For Firebase JS SDK v7.20.0 and later, measurementId is optional
  var firebaseConfig = {
    apiKey: "AIzaSyCSfh3lBzcXLr9LWw_eX5khoj9b1T1hzLA",
    authDomain: "lpmap-a74b3.firebaseapp.com",
    projectId: "lpmap-a74b3",
    storageBucket: "lpmap-a74b3.appspot.com",
    messagingSenderId: "21504753221",
    appId: "1:21504753221:web:bd76d94f827ece3173ad2c",
    measurementId: "G-EXY66V2H9P"
  };
  // Initialize Firebase
  firebase.initializeApp(firebaseConfig);
  firebase.analytics();
</script>
```

To remove null-safety, change the environment in `pubspec.yaml`:
```
environment:
  sdk: ">=2.7.0 <3.0.0"
```

To add GG Map add in `index.html`:
```
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDGf7LLHW_gqmpsbJyhhFh9mocS6WrVoIk"></script>
```
