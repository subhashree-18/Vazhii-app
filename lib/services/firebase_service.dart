import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initializes Firebase safely with graceful fallback for local development
  Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        return;
      }

      await Firebase.initializeApp();
      _isInitialized = true;
      debugPrint('[FirebaseService] Firebase initialized successfully.');
    } catch (e) {
      _isInitialized = false;
      debugPrint(
        '[FirebaseService] Running in local/offline fallback mode. '
        'Firebase not configured yet: $e. '
        'To connect live Firebase, run "flutterfire configure" or add google-services.json.',
      );
    }
  }
}

