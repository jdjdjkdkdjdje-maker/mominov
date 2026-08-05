import 'package:url_launcher/url_launcher.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class PaymentRepository {
  final ApiClient _client = ApiClient.instance;

  Future<String?> initiatePayment({required String orderId, required String method}) async {
    final res = await _client.post(ApiEndpoints.initiatePayment, data: {
      'orderId': orderId,
      'method': method,
    });
    return res['paymentUrl'] as String?;
  }

  Future<bool> openPaymentUrl(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
