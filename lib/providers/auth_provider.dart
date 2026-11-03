import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<UserModel?>? _authSubscription;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  String get currentUserId => _user?.userId ?? 'guest_user';

  AuthProvider() {
    // Listen to auth changes
    _authSubscription = AuthService.instance.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await AuthService.instance.registerWithEmail(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      // Save profile to Cloud Firestore users collection
      await FirestoreService.instance.saveUser(user);

      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Clean exception string if it begins with "Exception: "
      final msg = e.toString().replaceFirst('Exception: ', '');
      _errorMessage = msg;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await AuthService.instance.signInWithEmail(
        email: email,
        password: password,
      );

      // Fetch latest profile from Cloud Firestore users collection
      final profile = await FirestoreService.instance.getUser(user.userId);
      _user = profile ?? user;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      _errorMessage = msg;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<UserModel> continueAsGuest({String? name, String? phone}) async {
    final user = await AuthService.instance.signInAsGuest(
      name: name,
      phone: phone,
    );
    _user = user;
    notifyListeners();
    return user;
  }

  Future<void> updateProfile({required String name, required String phone}) async {
    if (_user != null) {
      final updated = _user!.copyWith(name: name, phone: phone);
      _user = updated;
      AuthService.instance.updateProfile(name: name, phone: phone);
      await FirestoreService.instance.saveUser(updated);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthService.instance.signOut();
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
