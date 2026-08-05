import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_config.dart';
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';

/// Backendga barcha so'rovlar shu klient orqali yuboriladi.
/// 401 kelsa — avtomatik `refresh` endpointi orqali tokenni yangilaydi va
/// so'rovni bir marta qayta yuboradi.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '${AppConfig.apiBaseUrl}/api/v1',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.instance.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final isAuthEndpoint = error.requestOptions.path.contains('/auth/');
          if (error.response?.statusCode == 401 && !isAuthEndpoint && !_isRetried(error.requestOptions)) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              final retryRequest = await _retry(error.requestOptions);
              return handler.resolve(retryRequest);
            }
          }
          return handler.next(error);
        },
      ),
    );

    if (AppConfig.enableNetworkLogs) {
      _dio.interceptors.add(PrettyDioLogger(requestBody: true, responseBody: true, compact: true));
    }
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;
  bool _isRefreshing = false;

  bool _isRetried(RequestOptions options) => options.extra['retried'] == true;

  Future<bool> _tryRefreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;
    try {
      final refreshToken = await SecureStorage.instance.refreshToken;
      if (refreshToken == null) return false;

      final response = await Dio(BaseOptions(baseUrl: '${AppConfig.apiBaseUrl}/api/v1')).post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final newAccess = response.data['accessToken'] as String;
      final newRefresh = response.data['refreshToken'] as String;
      await SecureStorage.instance.saveTokens(accessToken: newAccess, refreshToken: newRefresh);
      return true;
    } catch (_) {
      await SecureStorage.instance.clear();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await SecureStorage.instance.accessToken;
    final options = Options(method: requestOptions.method, headers: {
      ...requestOptions.headers,
      'Authorization': 'Bearer $token',
    });
    requestOptions.extra['retried'] = true;
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      return _asMap(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<dynamic>> getList(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      if (res.data is List) return res.data as List<dynamic>;
      if (res.data is Map && res.data['data'] is List) return res.data['data'] as List<dynamic>;
      if (res.data is Map && res.data['items'] is List) return res.data['items'] as List<dynamic>;
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    try {
      final res = await _dio.post(path, data: data);
      return _asMap(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> patch(String path, {dynamic data}) async {
    try {
      final res = await _dio.patch(path, data: data);
      return _asMap(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    return {'data': data};
  }
}
