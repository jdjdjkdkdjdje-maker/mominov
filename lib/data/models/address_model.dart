enum AddressType { home, work, other }

AddressType addressTypeFromString(String? value) {
  switch (value) {
    case 'work':
      return AddressType.work;
    case 'other':
      return AddressType.other;
    default:
      return AddressType.home;
  }
}

String addressTypeToString(AddressType type) => type.name;

class AddressModel {
  final String id;
  final String? title;
  final AddressType type;
  final String addressLine;
  final String? entrance;
  final String? floor;
  final String? apartment;
  final String? comment;
  final double latitude;
  final double longitude;
  final bool isDefault;

  AddressModel({
    required this.id,
    this.title,
    this.type = AddressType.home,
    required this.addressLine,
    this.entrance,
    this.floor,
    this.apartment,
    this.comment,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'] as String,
        title: json['title'] as String?,
        type: addressTypeFromString(json['type'] as String?),
        addressLine: json['addressLine'] as String? ?? '',
        entrance: json['entrance'] as String?,
        floor: json['floor'] as String?,
        apartment: json['apartment'] as String?,
        comment: json['comment'] as String?,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        isDefault: json['isDefault'] as bool? ?? false,
      );

  Map<String, dynamic> toCreateJson() => {
        'title': title,
        'type': addressTypeToString(type),
        'addressLine': addressLine,
        if (entrance != null) 'entrance': entrance,
        if (floor != null) 'floor': floor,
        if (apartment != null) 'apartment': apartment,
        if (comment != null) 'comment': comment,
        'latitude': latitude,
        'longitude': longitude,
        'isDefault': isDefault,
      };
}
