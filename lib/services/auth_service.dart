import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class AuthService {
  AuthService._() {
    // If Firebase is initialized later or already ready, listen to native state changes
    if (FirebaseService.instance.isInitialized) {
      _firebaseSubscription = FirebaseAuth.instance.authStateChanges().listen((fbUser) {
        if (fbUser == null && _currentUser != null && !_isLocalSession) {
          _currentUser = null;
          _authStreamController.add(null);
        }
      });
    }
  }

  static final AuthService instance = AuthService._();

  final _authStreamController = StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get authStateChanges => _authStreamController.stream;

  StreamSubscription<User?>? _firebaseSubscription;
  bool _isLocalSession = false;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  /// Human-friendly Tamil Nadu localized error message translator
  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No Vazhii account found with this email. Please register first.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please verify and try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email. Please sign in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too short. Please use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many login attempts. Please wait a minute before trying again.';
      case 'network-request-failed':
        return 'Network connection issue. Please check your mobile data or Wi-Fi.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact Vazhii support.';
      default:
        return e.message ?? 'An unexpected authentication error occurred. Please try again.';
    }
  }

  /// Register new user with Email, Password, Name, and Phone
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final cleanEmail = email.trim();
    final cleanName = name.trim();
    final cleanPhone = phone.trim();

    if (FirebaseService.instance.isInitialized) {
      try {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );

        final uid = credential.user?.uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
        final user = UserModel(
          userId: uid,
          name: cleanName,
          phone: cleanPhone,
          email: cleanEmail,
          createdAt: DateTime.now(),
        );

        _isLocalSession = false;
        _currentUser = user;
        _authStreamController.add(_currentUser);
        return user;
      } on FirebaseAuthException catch (e) {
        debugPrint('[AuthService] Firebase registration error: ${e.code} - ${e.message}');
        throw Exception(_mapFirebaseAuthError(e));
      } catch (e) {
        throw Exception('Registration failed: $e');
      }
    } else {
      // Local fallback mode
      final user = UserModel(
        userId: 'local_${DateTime.now().millisecondsSinceEpoch}',
        name: cleanName,
        phone: cleanPhone,
        email: cleanEmail,
        createdAt: DateTime.now(),
      );

      _isLocalSession = true;
      _currentUser = user;
      _authStreamController.add(_currentUser);
      return user;
    }
  }

  /// Sign in with Email and Password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();

    if (FirebaseService.instance.isInitialized) {
      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );

        final uid = credential.user?.uid ?? 'user_123';
        final user = UserModel(
          userId: uid,
          name: credential.user?.displayName ?? 'Traveler',
          phone: credential.user?.phoneNumber ?? '',
          email: cleanEmail,
          createdAt: DateTime.now(),
        );

        _isLocalSession = false;
        _currentUser = user;
        _authStreamController.add(_currentUser);
        return user;
      } on FirebaseAuthException catch (e) {
        debugPrint('[AuthService] Firebase sign-in error: ${e.code} - ${e.message}');
        throw Exception(_mapFirebaseAuthError(e));
      } catch (e) {
        throw Exception('Sign-in failed: $e');
      }
    } else {
      // Local fallback mode
      final user = UserModel(
        userId: 'local_user_456',
        name: 'Demo Traveler',
        phone: '9876543210',
        email: cleanEmail,
        createdAt: DateTime.now(),
      );

      _isLocalSession = true;
      _currentUser = user;
      _authStreamController.add(_currentUser);
      return user;
    }
  }

  /// Guest / Anonymous sign-in for seamless booking
  Future<UserModel> signInAsGuest({
    String? name,
    String? phone,
  }) async {
    if (FirebaseService.instance.isInitialized) {
      try {
        final credential = await FirebaseAuth.instance.signInAnonymously();
        final uid = credential.user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

        final user = UserModel(
          userId: uid,
          name: name?.trim().isNotEmpty == true ? name!.trim() : 'Guest Traveler',
          phone: phone?.trim() ?? '',
          email: 'guest@vazhii.app',
          createdAt: DateTime.now(),
        );

        _isLocalSession = false;
        _currentUser = user;
        _authStreamController.add(_currentUser);
        return user;
      } catch (e) {
        debugPrint('[AuthService] Guest sign-in error: $e');
      }
    }

    // Local fallback mode
    final user = UserModel(
      userId: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: name?.trim().isNotEmpty == true ? name!.trim() : 'Guest Traveler',
      phone: phone?.trim() ?? '9876543210',
      email: 'guest@vazhii.app',
      createdAt: DateTime.now(),
    );

    _isLocalSession = true;
    _currentUser = user;
    _authStreamController.add(_currentUser);
    return user;
  }

  /// Update current user profile
  void updateProfile({required String name, required String phone}) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(name: name, phone: phone);
      _authStreamController.add(_currentUser);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (FirebaseService.instance.isInitialized) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint('[AuthService] Sign out error: $e');
      }
    }

    _currentUser = null;
    _isLocalSession = false;
    _authStreamController.add(null);
  }

  void dispose() {
    _firebaseSubscription?.cancel();
  }
}
