import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthResult {
  final UserModel user;
  final bool isNewUser;
  AuthResult({required this.user, this.isNewUser = false});
}

class AuthRepository {
  final ApiClient _client = ApiClient.instance;

  Future<void> sendOtp(String phoneNumber) async {
    await _client.post(ApiEndpoints.sendOtp, data: {'phoneNumber': phoneNumber});
  }

  Future<AuthResult> verifyOtp({required String phoneNumber, required String code}) async {
    final res = await _client.post(ApiEndpoints.verifyOtp, data: {
      'phoneNumber': phoneNumber,
      'code': code,
    });
    return _handleAuthResponse(res);
  }

  Future<AuthResult> socialLogin({required String provider, required String idToken}) async {
    final res = await _client.post(ApiEndpoints.socialLogin, data: {
      'provider': provider,
      'idToken': idToken,
    });
    return _handleAuthResponse(res);
  }

  Future<AuthResult> _handleAuthResponse(Map<String, dynamic> res) async {
    final accessToken = res['accessToken'] as String;
    final refreshToken = res['refreshToken'] as String;
    await SecureStorage.instance.saveTokens(accessToken: accessToken, refreshToken: refreshToken);

    final userJson = res['user'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userJson);
    await SecureStorage.instance.saveSession(userId: user.id, role: user.role.name);

    return AuthResult(user: user, isNewUser: res['isNewUser'] as bool? ?? false);
  }

  Future<void> logout() async {
    await SecureStorage.instance.clear();
  }
}
