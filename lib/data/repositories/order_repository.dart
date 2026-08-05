import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/payment_method_model.dart';

class OrderRepository {
  final ApiClient _client = ApiClient.instance;

  Future<OrderModel> createOrder({
    required String restaurantId,
    String? addressId,
    required String orderType,
    required List<CartItemModel> items,
    String? promoCode,
    double? bonusToUse,
    required PaymentMethod paymentMethod,
    DateTime? scheduledAt,
    String? customerComment,
  }) async {
    final res = await _client.post(ApiEndpoints.orders, data: {
      'restaurantId': restaurantId,
      if (addressId != null) 'addressId': addressId,
      'orderType': orderType,
      'items': items.map((i) => i.toOrderItemJson()).toList(),
      if (promoCode != null && promoCode.isNotEmpty) 'promoCode': promoCode,
      if (bonusToUse != null && bonusToUse > 0) 'bonusToUse': bonusToUse,
      'paymentMethod': paymentMethod.apiValue,
      if (scheduledAt != null) 'scheduledAt': scheduledAt.toIso8601String(),
      if (customerComment != null && customerComment.isNotEmpty) 'customerComment': customerComment,
    });
    return OrderModel.fromJson(res);
  }

  Future<List<OrderModel>> myOrders() async {
    final res = await _client.getList(ApiEndpoints.myOrders);
    return res.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrderModel> getById(String id) async {
    final res = await _client.get(ApiEndpoints.order(id));
    return OrderModel.fromJson(res);
  }

  Future<OrderModel> cancel(String id, {String? reason}) async {
    final res = await _client.patch('${ApiEndpoints.order(id)}/status', data: {
      'status': 'cancelled_by_customer',
      if (reason != null) 'cancellationReason': reason,
    });
    return OrderModel.fromJson(res);
  }
}
