class BannerModel {
  final String id;
  final String imageUrl;
  final String? title;
  final String? linkType;
  final String? linkValue;

  BannerModel({required this.id, required this.imageUrl, this.title, this.linkType, this.linkValue});

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: json['id'] as String,
        imageUrl: json['imageUrl'] as String? ?? '',
        title: json['title'] as String?,
        linkType: json['linkType'] as String?,
        linkValue: json['linkValue'] as String?,
      );
}

enum PromoType { percent, amount, freeDelivery }

class PromoCodeModel {
  final String id;
  final String code;
  final PromoType type;
  final double value;
  final double? maxDiscount;
  final double? minOrderAmount;

  PromoCodeModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.maxDiscount,
    this.minOrderAmount,
  });

  factory PromoCodeModel.fromJson(Map<String, dynamic> json) => PromoCodeModel(
        id: json['id'] as String,
        code: json['code'] as String? ?? '',
        type: _typeFrom(json['type'] as String?),
        value: (json['value'] as num?)?.toDouble() ?? 0,
        maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
        minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble(),
      );

  static PromoType _typeFrom(String? v) {
    switch (v) {
      case 'amount':
        return PromoType.amount;
      case 'free_delivery':
        return PromoType.freeDelivery;
      default:
        return PromoType.percent;
    }
  }
}
