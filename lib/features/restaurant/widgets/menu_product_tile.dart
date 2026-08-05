import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../shared/widgets/common_widgets.dart';

class MenuProductTile extends StatelessWidget {
  final ProductModel product;
  const MenuProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Opacity(
        opacity: product.isAvailable ? 1 : 0.5,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: Theme.of(context).textTheme.titleLarge),
                    if (product.description != null) ...[
                      const SizedBox(height: 4),
                      Text(product.description!,
                          maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                    const SizedBox(height: 8),
                    PriceText(price: product.price, oldPrice: product.oldPrice),
                    if (!product.isAvailable) ...[
                      const SizedBox(height: 4),
                      const Text('Tugagan', style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: product.primaryImage,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  placeholder: (c, u) => Container(width: 84, height: 84, color: AppColors.lightBorder),
                  errorWidget: (c, u, e) => Container(
                    width: 84,
                    height: 84,
                    color: AppColors.lightBorder,
                    child: const Icon(Icons.fastfood_rounded, color: AppColors.lightTextSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
