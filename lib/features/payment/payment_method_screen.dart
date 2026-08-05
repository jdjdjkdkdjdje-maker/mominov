import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_strings.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../state/order_provider.dart';
import '../../state/repository_providers.dart';

/// Click/Payme/Uzum Bank kabi tashqi to'lov provayderiga yo'naltirish.
/// Backend `POST /payments/initiate` orqali to'lov sahifasi URL'ini qaytaradi
/// (bosqich-3 README'siga mos: `paymentUrl`).
class PaymentMethodScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String? method;
  const PaymentMethodScreen({super.key, required this.orderId, this.method});

  @override
  ConsumerState<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  bool _isProcessing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initiate());
  }

  Future<void> _initiate() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });
    try {
      final url = await ref.read(paymentRepositoryProvider).initiatePayment(
            orderId: widget.orderId,
            method: widget.method ?? 'click',
          );
      if (url == null) {
        setState(() {
          _error = "To'lov havolasi olinmadi";
          _isProcessing = false;
        });
        return;
      }
      await ref.read(paymentRepositoryProvider).openPaymentUrl(url);
      if (mounted) {
        // Foydalanuvchi tashqi brauzerdan qaytgach, buyurtma holatini tekshiramiz.
        setState(() => _isProcessing = false);
      }
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('payment_title'))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _isProcessing
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.mango),
                    SizedBox(height: 16),
                    Text("To'lov sahifasiga yo'naltirilmoqda..."),
                  ],
                )
              : _error != null
                  ? ErrorRetryView(message: _error!, onRetry: _initiate)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.payments_rounded, size: 56, color: AppColors.mango),
                        const SizedBox(height: 16),
                        const Text("To'lovni brauzerda yakunlagandan so'ng, buyurtma holatini tekshiramiz"),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            await ref.read(orderTrackingProvider(widget.orderId).notifier).refresh();
                            if (context.mounted) context.pushReplacement('/order/${widget.orderId}');
                          },
                          child: const Text("Holatni tekshirish"),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(onPressed: _initiate, child: const Text("Qayta urinish")),
                      ],
                    ),
        ),
      ),
    );
  }
}
