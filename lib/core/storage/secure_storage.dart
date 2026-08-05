import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Access/refresh tokenlarni va qurilma identifikatorini xavfsiz saqlash.
class SecureStorage {
  SecureStorage._();
  static final SecureStorage instance = SecureStorage._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUserId = 'user_id';
  static const _kUserRole = 'user_role';

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    await _storage.write(key: _kRefreshToken, value: refreshToken);
  }

  Future<String?> get accessToken => _storage.read(key: _kAccessToken);
  Future<String?> get refreshToken => _storage.read(key: _kRefreshToken);

  Future<void> saveSession({required String userId, required String role}) async {
    await _storage.write(key: _kUserId, value: userId);
    await _storage.write(key: _kUserRole, value: role);
  }

  Future<String?> get userId => _storage.read(key: _kUserId);
  Future<String?> get userRole => _storage.read(key: _kUserRole);

  Future<bool> get hasSession async => (await accessToken) != null;

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
