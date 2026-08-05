import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../shared/widgets/common_widgets.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final isOpen = restaurant.isOpenNow;
    return GestureDetector(
      onTap: () => context.push('/restaurant/${restaurant.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: CachedNetworkImage(
                    imageUrl: restaurant.coverImageUrl ?? restaurant.logoUrl ?? '',
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => Container(height: 140, color: AppColors.lightBorder),
                    errorWidget: (c, u, e) => Container(
                      height: 140,
                      color: AppColors.lightBorder,
                      child: const Icon(Icons.restaurant_rounded, color: AppColors.lightTextSecondary, size: 32),
                    ),
                  ),
                ),
                if (!isOpen)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      alignment: Alignment.center,
                      child: const Text('Yopiq', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                if (restaurant.isFeatured)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.mango, borderRadius: BorderRadius.circular(8)),
                      child: const Text('TOP', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(restaurant.name,
                            style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      RatingBadge(rating: restaurant.rating, reviewsCount: restaurant.reviewsCount),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.delivery_dining_rounded, size: 16, color: AppColors.lightTextSecondary),
                      const SizedBox(width: 4),
                      Text(formatSum(restaurant.deliveryFee), style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(width: 12),
                      const Icon(Icons.schedule_rounded, size: 16, color: AppColors.lightTextSecondary),
                      const SizedBox(width: 4),
                      Text('${restaurant.avgPreparationMin} min', style: Theme.of(context).textTheme.bodyMedium),
                      if (restaurant.distanceKm != null) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on_rounded, size: 16, color: AppColors.lightTextSecondary),
                        const SizedBox(width: 4),
                        Text('${restaurant.distanceKm!.toStringAsFixed(1)} km', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
