import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:flutter/foundation.dart';

class EnvConfig {
  static Future<void> load() async {
    try {
      await dotenv.dotenv.load(fileName: '.env');

      // Check if any environment variables were loaded
      if (dotenv.dotenv.env.isEmpty) {
        throw Exception('Failed to load .env file - file not found or empty');
      }
      // Print loaded environment variables for debugging (without sensitive values)
      debugPrint(
        'Environment variables loaded successfully. Keys found: ${dotenv.dotenv.env.keys.join(', ')}',
      );

      // Verify all required Firebase keys are present
      final requiredKeys = [
        'FIREBASE_API_KEY',
        'FIREBASE_AUTH_DOMAIN',
        'FIREBASE_PROJECT_ID',
        'FIREBASE_STORAGE_BUCKET',
        'FIREBASE_MESSAGING_SENDER_ID',
        'FIREBASE_APP_ID',
        'FIREBASE_MEASUREMENT_ID',
      ];

      final missingKeys =
          requiredKeys
              .where(
                (key) =>
                    dotenv.dotenv.env[key] == null ||
                    dotenv.dotenv.env[key]!.isEmpty,
              )
              .toList();

      if (missingKeys.isNotEmpty) {
        throw Exception(
          'Missing required environment variables: ${missingKeys.join(', ')}',
        );
      }
    } catch (e) {
      debugPrint('Error loading environment variables: $e');
      rethrow;
    }
  }

  static String get firebaseApiKey {
    final value = dotenv.dotenv.env['FIREBASE_API_KEY'];
    if (value == null || value.isEmpty) {
      throw Exception('FIREBASE_API_KEY is not set in .env file');
    }
    return value;
  }

  static String get firebaseAuthDomain {
    final value = dotenv.dotenv.env['FIREBASE_AUTH_DOMAIN'];
    if (value == null || value.isEmpty) {
      throw Exception('FIREBASE_AUTH_DOMAIN is not set in .env file');
    }
    return value;
  }

  static String get firebaseProjectId {
    final value = dotenv.dotenv.env['FIREBASE_PROJECT_ID'];
    if (value == null || value.isEmpty) {
      throw Exception('FIREBASE_PROJECT_ID is not set in .env file');
    }
    return value;
  }

  static String get firebaseStorageBucket {
    final value = dotenv.dotenv.env['FIREBASE_STORAGE_BUCKET'];
    if (value == null || value.isEmpty) {
      throw Exception('FIREBASE_STORAGE_BUCKET is not set in .env file');
    }
    return value;
  }

  static String get firebaseMessagingSenderId {
    final value = dotenv.dotenv.env['FIREBASE_MESSAGING_SENDER_ID'];
    if (value == null || value.isEmpty) {
      throw Exception('FIREBASE_MESSAGING_SENDER_ID is not set in .env file');
    }
    return value;
  }

  static String get firebaseAppId {
    final value = dotenv.dotenv.env['FIREBASE_APP_ID'];
    if (value == null || value.isEmpty) {
      throw Exception('FIREBASE_APP_ID is not set in .env file');
    }
    return value;
  }

  static String get firebaseMeasurementId {
    final value = dotenv.dotenv.env['FIREBASE_MEASUREMENT_ID'];
    if (value == null || value.isEmpty) {
      throw Exception('FIREBASE_MEASUREMENT_ID is not set in .env file');
    }
    return value;
  }
}
