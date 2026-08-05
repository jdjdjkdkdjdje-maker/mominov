class ProductVariantModel {
  final String id;
  final String name;
  final double extraPrice;
  final bool isDefault;

  ProductVariantModel({required this.id, required this.name, this.extraPrice = 0, this.isDefault = false});

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) => ProductVariantModel(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        extraPrice: (json['extraPrice'] as num?)?.toDouble() ?? 0,
        isDefault: json['isDefault'] as bool? ?? false,
      );
}

class ProductAddonModel {
  final String id;
  final String name;
  final double price;
  final int maxQuantity;

  ProductAddonModel({required this.id, required this.name, this.price = 0, this.maxQuantity = 1});

  factory ProductAddonModel.fromJson(Map<String, dynamic> json) => ProductAddonModel(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        maxQuantity: json['maxQuantity'] as int? ?? 1,
      );
}

class ProductModel {
  final String id;
  final String restaurantId;
  final String? categoryId;
  final String name;
  final String? description;
  final double price;
  final double? oldPrice;
  final double discountPercent;
  final int? calories;
  final String? ingredients;
  final bool isAvailable;
  final double rating;
  final int reviewsCount;
  final int ordersCount;
  final List<String> images;
  final List<ProductVariantModel> variants;
  final List<ProductAddonModel> addons;

  ProductModel({
    required this.id,
    required this.restaurantId,
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.oldPrice,
    this.discountPercent = 0,
    this.calories,
    this.ingredients,
    this.isAvailable = true,
    this.rating = 0,
    this.reviewsCount = 0,
    this.ordersCount = 0,
    this.images = const [],
    this.variants = const [],
    this.addons = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String,
        restaurantId: json['restaurantId'] as String? ?? '',
        categoryId: json['categoryId'] as String?,
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        oldPrice: (json['oldPrice'] as num?)?.toDouble(),
        discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0,
        calories: json['calories'] as int?,
        ingredients: json['ingredients'] as String?,
        isAvailable: json['isAvailable'] as bool? ?? true,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        reviewsCount: json['reviewsCount'] as int? ?? 0,
        ordersCount: json['ordersCount'] as int? ?? 0,
        images: ((json['images'] as List?) ?? [])
            .map((e) => (e is Map ? e['imageUrl'] ?? e['url'] : e).toString())
            .toList(),
        variants: ((json['variants'] as List?) ?? [])
            .map((e) => ProductVariantModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        addons: ((json['addons'] as List?) ?? [])
            .map((e) => ProductAddonModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  String get primaryImage => images.isNotEmpty ? images.first : '';
}
