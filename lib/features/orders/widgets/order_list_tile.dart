import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../../shared/widgets/common_widgets.dart';

/// Buyurtma holatiga mos rang va o'zbekcha yorliq (backend OrderStatus'ga mos).
(Color, String) orderStatusPresentation(OrderStatus status) {
  switch (status) {
    case OrderStatus.created:
      return (AppColors.statusCreated, 'Yaratildi');
    case OrderStatus.acceptedByRestaurant:
      return (AppColors.statusAccepted, 'Qabul qilindi');
    case OrderStatus.preparing:
      return (AppColors.statusPreparing, 'Tayyorlanmoqda');
    case OrderStatus.readyForPickup:
      return (AppColors.statusReady, 'Tayyor');
    case OrderStatus.courierAssigned:
      return (AppColors.statusCourier, 'Kuryer tayinlandi');
    case OrderStatus.pickedUp:
      return (AppColors.statusCourier, 'Kuryer oldi');
    case OrderStatus.onTheWay:
      return (AppColors.statusOnTheWay, "Yo'lda");
    case OrderStatus.delivered:
      return (AppColors.statusDelivered, 'Yetkazildi');
    case OrderStatus.cancelledByCustomer:
      return (AppColors.statusCancelled, 'Bekor qilindi');
    case OrderStatus.cancelledByRestaurant:
      return (AppColors.statusCancelled, 'Restoran bekor qildi');
    case OrderStatus.rejected:
      return (AppColors.statusCancelled, 'Rad etildi');
  }
}

class OrderListTile extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  const OrderListTile({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (color, label) = orderStatusPresentation(order.status);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: order.restaurantLogoUrl ?? '',
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorWidget: (c, u, e) => Container(
                  width: 52,
                  height: 52,
                  color: AppColors.lightBorder,
                  child: const Icon(Icons.storefront_rounded, color: AppColors.lightTextSecondary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.restaurantName ?? order.orderNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${order.items.length} ta mahsulot · ${formatSum(order.totalAmount)}',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            OrderStatusChip(label: label, color: color),
          ],
        ),
      ),
    );
  }
}
