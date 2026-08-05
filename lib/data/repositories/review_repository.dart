import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final ApiClient _client = ApiClient.instance;

  Future<List<ReviewModel>> byRestaurant(String restaurantId) async {
    final res = await _client.getList(ApiEndpoints.reviewsByRestaurant(restaurantId));
    return res.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ReviewModel>> byProduct(String productId) async {
    final res = await _client.getList(ApiEndpoints.reviewsByProduct(productId));
    return res.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> create({
    String? restaurantId,
    String? productId,
    String? orderId,
    required int rating,
    String? comment,
  }) async {
    await _client.post(ApiEndpoints.reviews, data: {
      if (restaurantId != null) 'restaurantId': restaurantId,
      if (productId != null) 'productId': productId,
      if (orderId != null) 'orderId': orderId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
  }
}
