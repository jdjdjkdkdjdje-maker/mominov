import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/order_model.dart';
import '../../l10n/app_strings.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../state/order_provider.dart';
import '../../state/repository_providers.dart';
import 'widgets/order_list_tile.dart';
import 'widgets/status_timeline.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  Future<void> _callCourier(String? phone) async {
    if (phone == null) return;
    await launchUrl(Uri.parse('tel:$phone'));
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buyurtmani bekor qilish'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'Sababi (ixtiyoriy)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Yopish')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Bekor qilish', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(orderTrackingProvider(orderId).notifier).cancel(reasonController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(orderTrackingProvider(orderId));
    final order = trackingState.order;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('track_order'))),
      body: trackingState.isLoading
          ? const LoadingView()
          : order == null
              ? ErrorRetryView(
                  message: trackingState.error ?? 'Xatolik',
                  onRetry: () => ref.read(orderTrackingProvider(orderId).notifier).refresh(),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('# ${order.orderNumber}', style: Theme.of(context).textTheme.headlineMedium),
                        OrderStatusChip(
                          label: orderStatusPresentation(order.status).$2,
                          color: orderStatusPresentation(order.status).$1,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Kuryer joylashuvi xaritada (10-band: jonli kuzatish).
                    if (order.status == OrderStatus.onTheWay || order.status == OrderStatus.pickedUp)
                      Container(
                        height: 220,
                        margin: const EdgeInsets.only(bottom: 16),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                        child: trackingState.courierLat != null
                            ? GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(trackingState.courierLat!, trackingState.courierLng!),
                                  zoom: 14,
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('courier'),
                                    position: LatLng(trackingState.courierLat!, trackingState.courierLng!),
                                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                                  ),
                                },
                                zoomControlsEnabled: false,
                              )
                            : Container(
                                color: AppColors.lightBorder,
                                alignment: Alignment.center,
                                child: const Text('Kuryer joylashuvi kutilmoqda...'),
                              ),
                      ),

                    if (!order.isCancelled)
                      StatusTimeline(currentStatus: order.status)
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cancel_rounded, color: AppColors.danger),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                order.cancellationReason ?? 'Buyurtma bekor qilindi',
                                style: const TextStyle(color: AppColors.danger),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    if (order.courierName != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.lightBorder),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(radius: 22, backgroundColor: AppColors.mango, child: Icon(Icons.delivery_dining_rounded, color: Colors.white)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(order.courierName!, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const Text('Kuryer', style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 12)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.call_rounded, color: AppColors.mango),
                              onPressed: () => _callCourier(order.courierPhone),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Text('Buyurtma tarkibi', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(item.productName)),
                              Text(formatSum(item.totalPrice)),
                            ],
                          ),
                        )),
                    const Divider(height: 24),
                    _row('Mahsulotlar', order.subtotal),
                    _row('Yetkazib berish', order.deliveryFee),
                    if (order.discountAmount > 0) _row('Chegirma', -order.discountAmount, color: AppColors.success),
                    if (order.bonusUsed > 0) _row('Bonus', -order.bonusUsed, color: AppColors.success),
                    const Divider(height: 24),
                    _row('Jami', order.totalAmount, bold: true),

                    if (order.customerComment != null) ...[
                      const SizedBox(height: 16),
                      Text('Izoh: ${order.customerComment}', style: Theme.of(context).textTheme.bodyMedium),
                    ],

                    const SizedBox(height: 24),
                    if (order.status == OrderStatus.created || order.status == OrderStatus.acceptedByRestaurant)
                      OutlinedButton(
                        onPressed: () => _confirmCancel(context, ref),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                        child: Text(context.tr('cancel_order')),
                      ),

                    if (order.status == OrderStatus.delivered) ...[
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showReviewSheet(context, ref, order),
                        icon: const Icon(Icons.star_rounded),
                        label: const Text('Baholash'),
                      ),
                    ],
                  ],
                ),
    );
  }

  Widget _row(String label, double amount, {bool bold = false, Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: bold ? const TextStyle(fontWeight: FontWeight.w700, fontSize: 16) : null),
            Text(
              (amount < 0 ? '-' : '') + formatSum(amount.abs()),
              style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: color),
            ),
          ],
        ),
      );

  void _showReviewSheet(BuildContext context, WidgetRef ref, OrderModel order) {
    double rating = 5;
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Restoranni baholang', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              StarRatingInput(rating: rating, onChanged: (v) => setSheetState(() => rating = v)),
              const SizedBox(height: 12),
              TextField(controller: commentController, maxLines: 3, decoration: const InputDecoration(hintText: 'Fikringiz (ixtiyoriy)')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(reviewRepositoryProvider).create(
                        restaurantId: order.restaurantId,
                        orderId: order.id,
                        rating: rating.round(),
                        comment: commentController.text.trim(),
                      );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Yuborish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
