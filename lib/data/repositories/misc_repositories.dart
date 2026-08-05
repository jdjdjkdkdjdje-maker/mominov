import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/banner_model.dart' show BannerModel, PromoCodeModel;
import '../models/notification_model.dart';

class BannerRepository {
  final ApiClient _client = ApiClient.instance;

  Future<List<BannerModel>> active() async {
    final res = await _client.getList(ApiEndpoints.banners);
    return res.map((e) => BannerModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class PromoCodeRepository {
  final ApiClient _client = ApiClient.instance;

  Future<List<PromoCodeModel>> myAvailablePromoCodes() async {
    final res = await _client.getList(ApiEndpoints.promoCodes);
    return res.map((e) => PromoCodeModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class BonusRepository {
  final ApiClient _client = ApiClient.instance;

  Future<List<Map<String, dynamic>>> history() async {
    final res = await _client.getList(ApiEndpoints.bonusHistory);
    return res.cast<Map<String, dynamic>>();
  }
}

class NotificationRepository {
  final ApiClient _client = ApiClient.instance;

  Future<List<NotificationModel>> list() async {
    final res = await _client.getList(ApiEndpoints.notifications);
    return res.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> registerDeviceToken(String token, String platform) async {
    await _client.post(ApiEndpoints.deviceToken, data: {'token': token, 'platform': platform});
  }

  Future<void> markRead(String id) => _client.patch(ApiEndpoints.notificationRead(id));
}
