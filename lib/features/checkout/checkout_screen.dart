import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/payment_method_model.dart';
import '../../l10n/app_strings.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../state/address_provider.dart';
import '../../state/auth_provider.dart';
import '../../state/cart_provider.dart';
import '../../state/repository_providers.dart';

enum _DeliveryMode { delivery, pickup }

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  _DeliveryMode _mode = _DeliveryMode.delivery;
  DateTime? _scheduledAt;
  final _commentController = TextEditingController();
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  bool _isSubmitting = false;
  String? _error;

  Future<void> _pickScheduledTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(minutes: 30))),
    );
    if (time == null) return;
    setState(() => _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _placeOrder() async {
    final cart = ref.read(cartProvider);
    final address = ref.read(selectedAddressProvider);

    if (cart.restaurantId == null) return;

    if (_mode == _DeliveryMode.delivery && address == null) {
      setState(() => _error = 'Yetkazib berish uchun manzil tanlang');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final order = await ref.read(orderRepositoryProvider).createOrder(
            restaurantId: cart.restaurantId!,
            addressId: _mode == _DeliveryMode.delivery ? address?.id : null,
            orderType: _scheduledAt != null ? 'scheduled' : (_mode == _DeliveryMode.delivery ? 'delivery' : 'pickup'),
            items: cart.items,
            promoCode: cart.appliedPromoCode,
            bonusToUse: cart.bonusToUse,
            paymentMethod: _paymentMethod,
            scheduledAt: _scheduledAt,
            customerComment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
          );

      ref.read(cartProvider.notifier).clear();

      if (!mounted) return;
      if (_paymentMethod.requiresRedirect) {
        context.pushReplacement('/payment/${order.id}', extra: _paymentMethod.apiValue);
      } else {
        context.pushReplacement('/order/${order.id}');
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final address = ref.watch(selectedAddressProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('checkout_title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _ModeButton(
                  label: context.tr('delivery'),
                  icon: Icons.delivery_dining_rounded,
                  selected: _mode == _DeliveryMode.delivery,
                  onTap: () => setState(() => _mode = _DeliveryMode.delivery),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ModeButton(
                  label: context.tr('pickup'),
                  icon: Icons.storefront_rounded,
                  selected: _mode == _DeliveryMode.pickup,
                  onTap: () => setState(() => _mode = _DeliveryMode.pickup),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_mode == _DeliveryMode.delivery)
            _SectionCard(
              icon: Icons.location_on_rounded,
              title: address?.title ?? 'Manzil tanlang',
              subtitle: address?.addressLine,
              onTap: () => context.push('/checkout/address-picker'),
            ),

          const SizedBox(height: 10),
          _SectionCard(
            icon: Icons.schedule_rounded,
            title: _scheduledAt == null ? 'Tez orada (standart)' : context.tr('scheduled'),
            subtitle: _scheduledAt == null
                ? "O'zgartirish uchun bosing"
                : '${_scheduledAt!.day}.${_scheduledAt!.month} ${_scheduledAt!.hour}:${_scheduledAt!.minute.toString().padLeft(2, '0')}',
            onTap: _pickScheduledTime,
            trailing: _scheduledAt != null
                ? IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => setState(() => _scheduledAt = null))
                : null,
          ),

          const SizedBox(height: 10),
          _SectionCard(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Izoh',
            subtitle: _commentController.text.isEmpty ? 'Kuryerga izoh qoldiring (ixtiyoriy)' : _commentController.text,
            onTap: _showCommentSheet,
          ),

          const SizedBox(height: 10),
          _SectionCard(
            icon: Icons.payments_rounded,
            title: "To'lov usuli",
            subtitle: _paymentMethod.displayNameUz,
            onTap: _showPaymentSheet,
          ),

          if (user != null && user.bonusBalance > 0) ...[
            const SizedBox(height: 10),
            _SectionCard(
              icon: Icons.stars_rounded,
              title: context.tr('bonus_balance'),
              subtitle: '${formatSum(user.bonusBalance)} mavjud',
              trailing: Switch(
                activeColor: AppColors.mango,
                value: cart.bonusToUse > 0,
                onChanged: (v) => ref.read(cartProvider.notifier).setBonusToUse(v ? user.bonusBalance : 0),
              ),
            ),
          ],

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Column(
              children: [
                _summaryRow('Mahsulotlar', cart.subtotal),
                if (cart.bonusToUse > 0) _summaryRow(context.tr('bonus_balance'), -cart.bonusToUse, color: AppColors.success),
                if (cart.promoDiscount > 0) _summaryRow('Chegirma', -cart.promoDiscount, color: AppColors.success),
                const Divider(height: 24),
                _summaryRow(
                  context.tr('total'),
                  (cart.subtotal - cart.bonusToUse - cart.promoDiscount).clamp(0, double.infinity),
                  bold: true,
                ),
              ],
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: 90),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _placeOrder,
          child: _isSubmitting
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(context.tr('place_order')),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool bold = false, Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: bold ? const TextStyle(fontWeight: FontWeight.w700, fontSize: 16) : null),
            Text(
              (amount < 0 ? '-' : '') + formatSum(amount.abs()),
              style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500, fontSize: bold ? 16 : 14, color: color),
            ),
          ],
        ),
      );

  void _showCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Izoh', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Masalan: domofon ishlamaydi'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Saqlash')),
          ],
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: PaymentMethod.values
              .map((m) => ListTile(
                    title: Text(m.displayNameUz),
                    trailing: _paymentMethod == m ? const Icon(Icons.check_circle_rounded, color: AppColors.mango) : null,
                    onTap: () {
                      setState(() => _paymentMethod = m);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ModeButton({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.mango.withOpacity(0.12) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.mango : AppColors.lightBorder, width: selected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.mango : AppColors.lightTextSecondary),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? AppColors.mango : null)),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SectionCard({required this.icon, required this.title, this.subtitle, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.mango),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (subtitle != null)
                    Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.lightTextSecondary),
          ],
        ),
      ),
    );
  }
}
