import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiClient _client = ApiClient.instance;

  Future<UserModel> getMe() async {
    final res = await _client.get(ApiEndpoints.me);
    return UserModel.fromJson(res);
  }

  Future<UserModel> updateMe({String? fullName, String? avatarUrl, String? language}) async {
    final res = await _client.patch(ApiEndpoints.me, data: {
      if (fullName != null) 'fullName': fullName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (language != null) 'language': language,
    });
    return UserModel.fromJson(res);
  }
}
