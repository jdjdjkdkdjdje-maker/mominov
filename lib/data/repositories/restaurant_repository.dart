import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/restaurant_model.dart';

class RestaurantRepository {
  final ApiClient _client = ApiClient.instance;

  Future<List<RestaurantModel>> list({
    String? search,
    double? latitude,
    double? longitude,
    double radiusKm = 10,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _client.getList(ApiEndpoints.restaurants, query: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'radiusKm': radiusKm,
      'page': page,
      'limit': limit,
    });
    return res.map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RestaurantModel> getById(String id) async {
    final res = await _client.get(ApiEndpoints.restaurant(id));
    return RestaurantModel.fromJson(res);
  }
}
