class CategoryModel {
  final String id;
  final String? restaurantId;
  final String name;
  final String? nameRu;
  final String? nameEn;
  final String? iconUrl;
  final int sortOrder;
  final bool isActive;

  CategoryModel({
    required this.id,
    this.restaurantId,
    required this.name,
    this.nameRu,
    this.nameEn,
    this.iconUrl,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        restaurantId: json['restaurantId'] as String?,
        name: json['name'] as String? ?? '',
        nameRu: json['nameRu'] as String?,
        nameEn: json['nameEn'] as String?,
        iconUrl: json['iconUrl'] as String?,
        sortOrder: json['sortOrder'] as int? ?? 0,
        isActive: json['isActive'] as bool? ?? true,
      );

  String localizedName(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return nameRu ?? name;
      case 'en':
        return nameEn ?? name;
      default:
        return name;
    }
  }
}
