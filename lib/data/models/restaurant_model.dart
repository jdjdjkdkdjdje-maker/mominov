class WorkingHoursModel {
  final int dayOfWeek;
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  WorkingHoursModel({required this.dayOfWeek, this.openTime, this.closeTime, this.isClosed = false});

  factory WorkingHoursModel.fromJson(Map<String, dynamic> json) => WorkingHoursModel(
        dayOfWeek: json['dayOfWeek'] as int? ?? 0,
        openTime: json['openTime'] as String?,
        closeTime: json['closeTime'] as String?,
        isClosed: json['isClosed'] as bool? ?? false,
      );
}

class RestaurantModel {
  final String id;
  final String name;
  final String slug;
  final String? logoUrl;
  final String? coverImageUrl;
  final List<String> images;
  final String? description;
  final String status;
  final double latitude;
  final double longitude;
  final String addressLine;
  final double deliveryFee;
  final double minOrderAmount;
  final int avgPreparationMin;
  final double rating;
  final int reviewsCount;
  final bool isFeatured;
  final List<WorkingHoursModel> workingHours;
  final double? distanceKm;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.coverImageUrl,
    this.images = const [],
    this.description,
    this.status = 'active',
    required this.latitude,
    required this.longitude,
    required this.addressLine,
    this.deliveryFee = 0,
    this.minOrderAmount = 0,
    this.avgPreparationMin = 20,
    this.rating = 0,
    this.reviewsCount = 0,
    this.isFeatured = false,
    this.workingHours = const [],
    this.distanceKm,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) => RestaurantModel(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        logoUrl: json['logoUrl'] as String?,
        coverImageUrl: json['coverImageUrl'] as String?,
        images: ((json['images'] as List?) ?? [])
            .map((e) => (e is Map ? e['imageUrl'] ?? e['url'] : e).toString())
            .toList(),
        description: json['description'] as String?,
        status: json['status'] as String? ?? 'active',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        addressLine: json['addressLine'] as String? ?? '',
        deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
        minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0,
        avgPreparationMin: json['avgPreparationMin'] as int? ?? 20,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        reviewsCount: json['reviewsCount'] as int? ?? 0,
        isFeatured: json['isFeatured'] as bool? ?? false,
        workingHours: ((json['workingHours'] as List?) ?? [])
            .map((e) => WorkingHoursModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      );

  bool get isOpenNow {
    if (workingHours.isEmpty) return true;
    final now = DateTime.now();
    final today = workingHours.firstWhere(
      (w) => w.dayOfWeek == now.weekday % 7,
      orElse: () => WorkingHoursModel(dayOfWeek: now.weekday % 7, isClosed: true),
    );
    if (today.isClosed || today.openTime == null || today.closeTime == null) return false;
    final nowMinutes = now.hour * 60 + now.minute;
    final open = _toMinutes(today.openTime!);
    final close = _toMinutes(today.closeTime!);
    return nowMinutes >= open && nowMinutes <= close;
  }

  int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
