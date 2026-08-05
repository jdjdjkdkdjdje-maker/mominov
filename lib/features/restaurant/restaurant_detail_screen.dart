import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../state/restaurant_detail_provider.dart';
import 'widgets/menu_product_tile.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final String restaurantId;
  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  ConsumerState<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends ConsumerState<RestaurantDetailScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final restaurantAsync = ref.watch(restaurantDetailProvider(widget.restaurantId));
    final productsAsync = ref.watch(restaurantProductsProvider(widget.restaurantId));
    final reviewsAsync = ref.watch(restaurantReviewsProvider(widget.restaurantId));

    return Scaffold(
      body: restaurantAsync.when(
        loading: () => const LoadingView(),
        error: (e, st) => ErrorRetryView(
          message: e.toString(),
          onRetry: () => ref.invalidate(restaurantDetailProvider(widget.restaurantId)),
        ),
        data: (restaurant) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: restaurant.coverImageUrl ?? restaurant.logoUrl ?? '',
                    fit: BoxFit.cover,
                    errorWidget: (c, u, e) => Container(color: AppColors.lightBorder),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(restaurant.name, style: Theme.of(context).textTheme.displayMedium)),
                          RatingBadge(rating: restaurant.rating, reviewsCount: restaurant.reviewsCount),
                        ],
                      ),
                      if (restaurant.description != null) ...[
                        const SizedBox(height: 6),
                        Text(restaurant.description!, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _infoChip(Icons.delivery_dining_rounded, formatSum(restaurant.deliveryFee)),
                          const SizedBox(width: 8),
                          _infoChip(Icons.schedule_rounded, '${restaurant.avgPreparationMin} min'),
                          const SizedBox(width: 8),
                          _infoChip(
                            Icons.circle,
                            restaurant.isOpenNow ? 'Ochiq' : 'Yopiq',
                            color: restaurant.isOpenNow ? AppColors.success : AppColors.danger,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Minimal buyurtma: ${formatSum(restaurant.minOrderAmount)}',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: productsAsync.when(
                  data: (products) {
                    final categoryIds = products.map((p) => p.categoryId).whereType<String>().toSet();
                    if (categoryIds.isEmpty) return const SizedBox.shrink();
                    return SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: const Text('Barchasi'),
                              selected: _selectedCategoryId == null,
                              onSelected: (_) => setState(() => _selectedCategoryId = null),
                            ),
                          ),
                          ...categoryIds.map((id) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(id.substring(0, 6)),
                                  selected: _selectedCategoryId == id,
                                  onSelected: (_) => setState(() => _selectedCategoryId = id),
                                ),
                              )),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, st) => const SizedBox.shrink(),
                ),
              ),
              productsAsync.when(
                data: (products) {
                  final filtered = _selectedCategoryId == null
                      ? products
                      : products.where((p) => p.categoryId == _selectedCategoryId).toList();
                  if (filtered.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: EmptyStateView(icon: Icons.no_meals_rounded, title: 'Menyu bo\'sh'),
                      ),
                    );
                  }
                  return SliverList.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => MenuProductTile(product: filtered[i]),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: SizedBox(height: 300, child: LoadingView())),
                error: (e, st) => SliverToBoxAdapter(child: ErrorRetryView(message: e.toString(), onRetry: () {})),
              ),
              const SliverToBoxAdapter(child: SectionHeader(title: 'Sharhlar')),
              reviewsAsync.when(
                data: (reviews) {
                  if (reviews.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 24),
                        child: EmptyStateView(icon: Icons.rate_review_rounded, title: 'Hozircha sharhlar yo\'q'),
                      ),
                    );
                  }
                  return SliverList.builder(
                    itemCount: reviews.length > 5 ? 5 : reviews.length,
                    itemBuilder: (context, i) {
                      final r = reviews[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage:
                                      r.userAvatarUrl != null ? CachedNetworkImageProvider(r.userAvatarUrl!) : null,
                                ),
                                const SizedBox(width: 8),
                                Text(r.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                const Spacer(),
                                RatingBadge(rating: r.rating.toDouble()),
                              ],
                            ),
                            if (r.comment != null) ...[
                              const SizedBox(height: 6),
                              Text(r.comment!, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const SliverToBoxAdapter(child: SizedBox(height: 80, child: LoadingView())),
                error: (e, st) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, {Color? color}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.lightBorder.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color ?? AppColors.lightTextSecondary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
}
