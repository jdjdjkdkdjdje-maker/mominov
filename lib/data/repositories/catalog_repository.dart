import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class CatalogRepository {
  final ApiClient _client = ApiClient.instance;

  Future<List<CategoryModel>> categories({String? restaurantId}) async {
    final res = await _client.getList(ApiEndpoints.categories, query: {
      if (restaurantId != null) 'restaurantId': restaurantId,
    });
    return res.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ProductModel>> productsByRestaurant(String restaurantId) async {
    final res = await _client.getList(ApiEndpoints.productsByRestaurant(restaurantId));
    return res.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ProductModel>> search(String query) async {
    final res = await _client.getList(ApiEndpoints.productSearch, query: {'q': query});
    return res.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ProductModel>> popular() async {
    final res = await _client.getList(ApiEndpoints.productPopular);
    return res.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProductModel> getById(String id) async {
    final res = await _client.get(ApiEndpoints.product(id));
    return ProductModel.fromJson(res);
  }
}
