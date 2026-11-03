import 'package:flutter_test/flutter_test.dart';
import 'package:vazhii/models/user_model.dart';
import 'package:vazhii/providers/auth_provider.dart';

void main() {
  group('AuthProvider Tests', () {
    test('Initial user is null and not authenticated', () {
      final auth = AuthProvider();
      expect(auth.user, isNull);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.currentUserId, 'guest_user');
    });

    test('Registering user sets current user profile', () async {
      final auth = AuthProvider();
      final success = await auth.register(
        email: 'test@vazhii.app',
        password: 'password123',
        name: 'Vazhii Traveler',
        phone: '9876543210',
      );

      expect(success, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.user?.name, 'Vazhii Traveler');
      expect(auth.user?.email, 'test@vazhii.app');
      expect(auth.user?.phone, '9876543210');
    });

    test('Sign in as guest sets guest traveler profile', () async {
      final auth = AuthProvider();
      final guest = await auth.continueAsGuest(name: 'Hill Explorer');

      expect(guest.name, 'Hill Explorer');
      expect(auth.isAuthenticated, isTrue);
      expect(auth.user?.name, 'Hill Explorer');
    });

    test('Updating profile modifies user information', () async {
      final auth = AuthProvider();
      await auth.continueAsGuest(name: 'Old Name', phone: '9000000000');
      await auth.updateProfile(name: 'New Name', phone: '9999999999');

      expect(auth.user?.name, 'New Name');
      expect(auth.user?.phone, '9999999999');
    });

    test('Logout clears user session', () async {
      final auth = AuthProvider();
      await auth.continueAsGuest();
      expect(auth.isAuthenticated, isTrue);

      await auth.logout();
      expect(auth.isAuthenticated, isFalse);
      expect(auth.user, isNull);
    });
  });

  group('UserModel Serialization Tests', () {
    test('toMap and fromMap preserves all fields', () {
      final now = DateTime.now();
      final user = UserModel(
        userId: 'u_123',
        name: 'Suresh Kumar',
        phone: '9840123456',
        email: 'suresh@example.com',
        createdAt: now,
      );

      final map = user.toMap();
      final reconstructed = UserModel.fromMap(map, 'u_123');

      expect(reconstructed.userId, 'u_123');
      expect(reconstructed.name, 'Suresh Kumar');
      expect(reconstructed.phone, '9840123456');
      expect(reconstructed.email, 'suresh@example.com');
    });
  });
}

