import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../state/auth_provider.dart';
import '../../state/home_provider.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/category_chips.dart';
import 'widgets/popular_product_card.dart';
import 'widgets/restaurant_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategoryId;

  Future<void> _refresh() async {
    ref.invalidate(bannersProvider);
    ref.invalidate(homeCategoriesProvider);
    ref.invalidate(popularProductsProvider);
    ref.invalidate(nearbyRestaurantsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final banners = ref.watch(bannersProvider);
    final categories = ref.watch(homeCategoriesProvider);
    final popularProducts = ref.watch(popularProductsProvider);
    final restaurants = ref.watch(nearbyRestaurantsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.mango,
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Assalomu alaykum,', style: Theme.of(context).textTheme.bodyMedium),
                          Text(
                            user?.fullName.isNotEmpty == true ? user!.fullName.split(' ').first : 'Mehmon',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.push('/profile/addresses'),
                        child: Row(
                          children: const [
                            Icon(Icons.location_on_rounded, color: AppColors.mango, size: 20),
                            SizedBox(width: 4),
                            Text('Manzil'),
                            Icon(Icons.keyboard_arrow_down_rounded),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: GestureDetector(
                    onTap: () => context.push('/search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search_rounded, color: AppColors.lightTextSecondary),
                          SizedBox(width: 8),
                          Text('Restoran yoki taom qidirish', style: TextStyle(color: AppColors.lightTextSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: banners.when(
                  data: (data) => Padding(padding: const EdgeInsets.only(bottom: 8), child: BannerCarousel(banners: data)),
                  loading: () => const SizedBox(height: 160),
                  error: (e, st) => const SizedBox.shrink(),
                ),
              ),
              SliverToBoxAdapter(
                child: categories.when(
                  data: (data) => CategoryChips(
                    categories: data,
                    selectedId: _selectedCategoryId,
                    onSelect: (id) => setState(() => _selectedCategoryId = id),
                  ),
                  loading: () => const SizedBox(height: 96),
                  error: (e, st) => const SizedBox.shrink(),
                ),
              ),
              SliverToBoxAdapter(
                child: popularProducts.when(
                  data: (data) {
                    if (data.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Eng ko\'p buyurtma qilingan'),
                        SizedBox(
                          height: 205,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: data.length,
                            itemBuilder: (context, i) => PopularProductCard(product: data[i]),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    );
                  },
                  loading: () => const SizedBox(height: 240, child: LoadingView()),
                  error: (e, st) => const SizedBox.shrink(),
                ),
              ),
              const SliverToBoxAdapter(child: SectionHeader(title: 'Mashhur restoranlar')),
              restaurants.when(
                data: (data) {
                  if (data.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: EmptyStateView(icon: Icons.storefront_rounded, title: 'Restoranlar topilmadi'),
                      ),
                    );
                  }
                  return SliverList.builder(
                    itemCount: data.length,
                    itemBuilder: (context, i) => RestaurantCard(restaurant: data[i]),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: SizedBox(height: 300, child: LoadingView())),
                error: (e, st) => SliverToBoxAdapter(
                  child: ErrorRetryView(message: e.toString(), onRetry: _refresh),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
