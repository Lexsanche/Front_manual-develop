// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyABEW8NSkrufaJMmC8OPvx1xtswaCchcrU',
    appId: '1:116827091526:web:c39b7c255d4608f8a59047',
    messagingSenderId: '116827091526',
    projectId: 'ambient-elf-416621',
    authDomain: 'ambient-elf-416621.firebaseapp.com',
    storageBucket: 'ambient-elf-416621.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBTZiXj4XY-6oFPHjRUPDuHTdkBzs7gwLY',
    appId: '1:116827091526:android:dc0f6b59833ec7b9a59047',
    messagingSenderId: '116827091526',
    projectId: 'ambient-elf-416621',
    storageBucket: 'ambient-elf-416621.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDHDLyEAMBjCOKFnaF9maSXeJs7DzdEDzA',
    appId: '1:116827091526:ios:393a7c26d583aabaa59047',
    messagingSenderId: '116827091526',
    projectId: 'ambient-elf-416621',
    storageBucket: 'ambient-elf-416621.appspot.com',
    iosBundleId: 'com.example.frontManual',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDHDLyEAMBjCOKFnaF9maSXeJs7DzdEDzA',
    appId: '1:116827091526:ios:0311eb2311edcb14a59047',
    messagingSenderId: '116827091526',
    projectId: 'ambient-elf-416621',
    storageBucket: 'ambient-elf-416621.appspot.com',
    iosBundleId: 'com.example.frontManual.RunnerTests',
  );
}