import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/banner_model.dart';
import '../data/models/category_model.dart';
import '../data/models/product_model.dart';
import '../data/models/restaurant_model.dart';
import 'location_provider.dart';
import 'repository_providers.dart';

final bannersProvider = FutureProvider<List<BannerModel>>((ref) {
  return ref.read(bannerRepositoryProvider).active();
});

final homeCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.read(catalogRepositoryProvider).categories();
});

final popularProductsProvider = FutureProvider<List<ProductModel>>((ref) {
  return ref.read(catalogRepositoryProvider).popular();
});

final nearbyRestaurantsProvider = FutureProvider<List<RestaurantModel>>((ref) async {
  final position = await ref.watch(userLocationProvider.future);
  return ref.read(restaurantRepositoryProvider).list(
        latitude: position?.latitude,
        longitude: position?.longitude,
      );
});

final restaurantSearchQueryProvider = StateProvider<String>((ref) => '');

final restaurantSearchResultsProvider = FutureProvider<List<RestaurantModel>>((ref) async {
  final query = ref.watch(restaurantSearchQueryProvider);
  if (query.trim().isEmpty) return [];
  final position = await ref.watch(userLocationProvider.future);
  return ref.read(restaurantRepositoryProvider).list(
        search: query,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );
});

final productSearchResultsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final query = ref.watch(restaurantSearchQueryProvider);
  if (query.trim().isEmpty) return [];
  return ref.read(catalogRepositoryProvider).search(query);
});
