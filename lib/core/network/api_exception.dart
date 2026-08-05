class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  factory ApiException.fromDioError(dynamic error) {
    try {
      final response = error.response;
      final data = response?.data;
      String msg = 'Kutilmagan xatolik yuz berdi';
      if (data is Map && data['message'] != null) {
        msg = data['message'] is List ? (data['message'] as List).join(', ') : data['message'].toString();
      }
      return ApiException(message: msg, statusCode: response?.statusCode, data: data);
    } catch (_) {
      return ApiException(message: "Internetga ulanishda muammo bo'ldi");
    }
  }

  @override
  String toString() => message;
}
