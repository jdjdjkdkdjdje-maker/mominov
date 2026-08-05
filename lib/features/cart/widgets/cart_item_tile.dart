import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../shared/widgets/common_widgets.dart';

class CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemTile({super.key, required this.item, required this.onQuantityChanged, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.cartItemId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.danger,
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
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
                imageUrl: item.product.primaryImage,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorWidget: (c, u, e) => Container(width: 64, height: 64, color: AppColors.lightBorder),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name, style: Theme.of(context).textTheme.titleMedium),
                  if (item.variant != null) Text(item.variant!.name, style: Theme.of(context).textTheme.bodyMedium),
                  if (item.selectedAddons.isNotEmpty)
                    Text(
                      item.selectedAddons.map((a) => a.name).join(', '),
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  PriceText(price: item.totalPrice, fontSize: 14),
                ],
              ),
            ),
            QuantityStepper(quantity: item.quantity, onChanged: onQuantityChanged),
          ],
        ),
      ),
    );
  }
}
