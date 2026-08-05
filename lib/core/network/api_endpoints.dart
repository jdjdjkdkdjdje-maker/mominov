/// Barcha yo'llar `uzum-tezkor-backend`dagi controller'lar bilan bir xil.
/// Bazaviy manzil: `${API_BASE_URL}/api/v1`
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const sendOtp = '/auth/otp/send';
  static const verifyOtp = '/auth/otp/verify';
  static const socialLogin = '/auth/social-login';
  static const refreshToken = '/auth/refresh';

  // Users
  static const me = '/users/me';

  // Addresses
  static const addresses = '/addresses';
  static String address(String id) => '/addresses/$id';

  // Restaurants
  static const restaurants = '/restaurants';
  static String restaurant(String id) => '/restaurants/$id';

  // Categories
  static const categories = '/categories';

  // Products
  static const productSearch = '/products/search';
  static const productPopular = '/products/popular';
  static String productsByRestaurant(String restaurantId) => '/products/restaurant/$restaurantId';
  static String product(String id) => '/products/$id';

  // Orders
  static const orders = '/orders';
  static const myOrders = '/orders/my';
  static String order(String id) => '/orders/$id';

  // Payments
  static const initiatePayment = '/payments/initiate';

  // Reviews
  static const reviews = '/reviews';
  static String reviewsByRestaurant(String restaurantId) => '/reviews/restaurant/$restaurantId';
  static String reviewsByProduct(String productId) => '/reviews/product/$productId';

  // Promo codes
  static const promoCodes = '/promocodes';

  // Bonus
  static const bonusHistory = '/bonus/history';

  // Notifications
  static const notifications = '/notifications';
  static const deviceToken = '/notifications/device-token';
  static String notificationRead(String id) => '/notifications/$id/read';

  // Banners
  static const banners = '/banners';
}
