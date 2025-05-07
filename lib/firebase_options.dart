import 'package:firebase_core/firebase_core.dart';
import 'config/env_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: EnvConfig.firebaseApiKey,
      authDomain: EnvConfig.firebaseAuthDomain,
      projectId: EnvConfig.firebaseProjectId,
      storageBucket: EnvConfig.firebaseStorageBucket,
      messagingSenderId: EnvConfig.firebaseMessagingSenderId,
      appId: EnvConfig.firebaseAppId,
      measurementId: EnvConfig.firebaseMeasurementId,
    );
  }
}
