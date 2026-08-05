import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/product_model.dart';
import '../data/models/restaurant_model.dart';
import '../data/models/review_model.dart';
import 'repository_providers.dart';

final restaurantDetailProvider = FutureProvider.family<RestaurantModel, String>((ref, id) {
  return ref.read(restaurantRepositoryProvider).getById(id);
});

final restaurantProductsProvider = FutureProvider.family<List<ProductModel>, String>((ref, restaurantId) {
  return ref.read(catalogRepositoryProvider).productsByRestaurant(restaurantId);
});

final restaurantReviewsProvider = FutureProvider.family<List<ReviewModel>, String>((ref, restaurantId) {
  return ref.read(reviewRepositoryProvider).byRestaurant(restaurantId);
});

final productDetailProvider = FutureProvider.family<ProductModel, String>((ref, id) {
  return ref.read(catalogRepositoryProvider).getById(id);
});

final productReviewsProvider = FutureProvider.family<List<ReviewModel>, String>((ref, productId) {
  return ref.read(reviewRepositoryProvider).byProduct(productId);
});
