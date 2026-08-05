enum UserRole { customer, restaurantOwner, courier, admin, superAdmin }

UserRole userRoleFromString(String? value) {
  switch (value) {
    case 'restaurant_owner':
      return UserRole.restaurantOwner;
    case 'courier':
      return UserRole.courier;
    case 'admin':
      return UserRole.admin;
    case 'super_admin':
      return UserRole.superAdmin;
    default:
      return UserRole.customer;
  }
}

class UserModel {
  final String id;
  final String? phoneNumber;
  final String? email;
  final String fullName;
  final String? avatarUrl;
  final UserRole role;
  final String language;
  final double bonusBalance;
  final String? referralCode;

  UserModel({
    required this.id,
    this.phoneNumber,
    this.email,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    this.language = 'uz',
    this.bonusBalance = 0,
    this.referralCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        phoneNumber: json['phoneNumber'] as String?,
        email: json['email'] as String?,
        fullName: json['fullName'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String?,
        role: userRoleFromString(json['role'] as String?),
        language: json['language'] as String? ?? 'uz',
        bonusBalance: (json['bonusBalance'] as num?)?.toDouble() ?? 0,
        referralCode: json['referralCode'] as String?,
      );

  UserModel copyWith({String? fullName, String? avatarUrl, String? language, double? bonusBalance}) => UserModel(
        id: id,
        phoneNumber: phoneNumber,
        email: email,
        fullName: fullName ?? this.fullName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        role: role,
        language: language ?? this.language,
        bonusBalance: bonusBalance ?? this.bonusBalance,
        referralCode: referralCode,
      );
}
