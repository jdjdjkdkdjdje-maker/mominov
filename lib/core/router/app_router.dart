import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/phone_screen.dart';
import '../../features/auth/profile_setup_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/checkout/address_picker_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/checkout/map_picker_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/orders/order_history_screen.dart';
import '../../features/orders/order_tracking_screen.dart';
import '../../features/payment/payment_method_screen.dart';
import '../../features/payment/payment_result_screen.dart';
import '../../features/product/product_detail_screen.dart';
import '../../features/profile/addresses_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/restaurant/restaurant_detail_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../shared/widgets/root_shell.dart';
import '../../state/auth_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Butun ilova navigatsiyasi shu yerda. Auth holatiga qarab
/// splash -> onboarding -> auth -> (profil to'ldirish) -> asosiy oqim.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final loggingIn = state.matchedLocation.startsWith('/auth');
      final atSplashOrOnboarding = state.matchedLocation == '/splash' || state.matchedLocation == '/onboarding';

      if (authState.status == AuthStatus.unknown) {
        return atSplashOrOnboarding ? null : '/splash';
      }
      if (authState.status == AuthStatus.unauthenticated) {
        return (loggingIn || state.matchedLocation == '/onboarding') ? null : '/onboarding';
      }
      // Authenticated
      if (authState.needsProfileSetup) {
        return state.matchedLocation == '/auth/profile-setup' ? null : '/auth/profile-setup';
      }
      if (loggingIn || atSplashOrOnboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/auth/phone', builder: (c, s) => const PhoneScreen()),
      GoRoute(
        path: '/auth/otp',
        builder: (c, s) => OtpScreen(phoneNumber: s.extra as String? ?? ''),
      ),
      GoRoute(path: '/auth/profile-setup', builder: (c, s) => const ProfileSetupScreen()),

      // Pastki navigatsiya (bottom nav) bilan asosiy 4 bo'lim.
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => RootShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
          GoRoute(path: '/search', builder: (c, s) => const SearchScreen()),
          GoRoute(path: '/orders', builder: (c, s) => const OrderHistoryScreen()),
          GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
        ],
      ),

      GoRoute(
        path: '/restaurant/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (c, s) => RestaurantDetailScreen(restaurantId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/product/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (c, s) => ProductDetailScreen(productId: s.pathParameters['id']!),
      ),
      GoRoute(path: '/cart', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const CartScreen()),
      GoRoute(path: '/checkout', parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const CheckoutScreen()),
      GoRoute(
        path: '/checkout/address-picker',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (c, s) => const AddressPickerScreen(),
      ),
      GoRoute(
        path: '/checkout/map-picker',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (c, s) => const MapPickerScreen(),
      ),
      GoRoute(
        path: '/payment/:orderId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (c, s) => PaymentMethodScreen(
          orderId: s.pathParameters['orderId']!,
          method: s.extra as String?,
        ),
      ),
      GoRoute(
        path: '/payment-result/:orderId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (c, s) => PaymentResultScreen(
          orderId: s.pathParameters['orderId']!,
          success: (s.extra as bool?) ?? true,
        ),
      ),
      GoRoute(
        path: '/order/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (c, s) => OrderTrackingScreen(orderId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile/addresses',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (c, s) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/profile/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (c, s) => const SettingsScreen(),
      ),
    ],
  );
});
