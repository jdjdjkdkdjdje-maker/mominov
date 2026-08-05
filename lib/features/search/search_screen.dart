import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../state/home_provider.dart';
import '../home/widgets/popular_product_card.dart';
import '../home/widgets/restaurant_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  Timer? _debounce;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(restaurantSearchQueryProvider.notifier).state = value;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(restaurantSearchQueryProvider);
    final restaurants = ref.watch(restaurantSearchResultsProvider);
    final products = ref.watch(productSearchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          decoration: const InputDecoration(
            hintText: 'Restoran yoki taom qidirish',
            border: InputBorder.none,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Restoranlar'), Tab(text: 'Taomlar')],
        ),
      ),
      body: query.trim().isEmpty
          ? const EmptyStateView(icon: Icons.search_rounded, title: 'Nimani qidiryapsiz?')
          : TabBarView(
              controller: _tabController,
              children: [
                restaurants.when(
                  data: (data) => data.isEmpty
                      ? const EmptyStateView(icon: Icons.storefront_rounded, title: 'Hech narsa topilmadi')
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: data.length,
                          itemBuilder: (context, i) => RestaurantCard(restaurant: data[i]),
                        ),
                  loading: () => const LoadingView(),
                  error: (e, st) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(restaurantSearchResultsProvider)),
                ),
                products.when(
                  data: (data) => data.isEmpty
                      ? const EmptyStateView(icon: Icons.fastfood_rounded, title: 'Hech narsa topilmadi')
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: data.length,
                          itemBuilder: (context, i) => PopularProductCard(product: data[i]),
                        ),
                  loading: () => const LoadingView(),
                  error: (e, st) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(productSearchResultsProvider)),
                ),
              ],
            ),
    );
  }
}
