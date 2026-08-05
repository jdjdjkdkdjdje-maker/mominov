import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_strings.dart';

class PaymentResultScreen extends StatelessWidget {
  final String orderId;
  final bool success;
  const PaymentResultScreen({super.key, required this.orderId, required this.success});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.error_rounded,
                size: 96,
                color: success ? AppColors.success : AppColors.danger,
              ),
              const SizedBox(height: 24),
              Text(
                success ? context.tr('payment_success') : context.tr('payment_failed'),
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.pushReplacement('/order/$orderId'),
                child: const Text('Buyurtmani ko\'rish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
