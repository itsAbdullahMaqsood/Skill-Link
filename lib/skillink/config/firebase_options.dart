// Values from the IoT project `google-services.json` (project iot-project-283d4).
// Used for Dart-only Firebase init so the Android `applicationId` (com.example.skilllink)
// does not need a second Firebase client entry in that file.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // RTDB test flow targets Android; other platforms skip init in main.
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBkhPnHDupNQ5b-wMrl3GpXtwDbNrmh_bM',
    appId: '1:702333759246:android:310ebe51c740ea336df15f',
    messagingSenderId: '702333759246',
    projectId: 'iot-project-283d4',
    storageBucket: 'iot-project-283d4.firebasestorage.app',
    databaseURL: 'https://iot-project-283d4-default-rtdb.firebaseio.com',
  );
}
