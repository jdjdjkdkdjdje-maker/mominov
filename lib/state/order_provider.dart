import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/order_model.dart';
import '../data/repositories/realtime_service.dart';
import 'repository_providers.dart';

final myOrdersProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) {
  return ref.read(orderRepositoryProvider).myOrders();
});

/// Bitta buyurtmani jonli kuzatish: dastlab REST orqali yuklanadi, so'ng
/// Socket.IO orqali holat/kuryer joylashuvi yangilanishlari tinglanadi
/// (backend RealtimeGateway bilan bir xil `order:{id}` xonasi).
class OrderTrackingState {
  final OrderModel? order;
  final bool isLoading;
  final String? error;
  final double? courierLat;
  final double? courierLng;

  const OrderTrackingState({this.order, this.isLoading = true, this.error, this.courierLat, this.courierLng});

  OrderTrackingState copyWith({
    OrderModel? order,
    bool? isLoading,
    String? error,
    double? courierLat,
    double? courierLng,
  }) =>
      OrderTrackingState(
        order: order ?? this.order,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        courierLat: courierLat ?? this.courierLat,
        courierLng: courierLng ?? this.courierLng,
      );
}

class OrderTrackingNotifier extends StateNotifier<OrderTrackingState> {
  final Ref ref;
  final String orderId;

  OrderTrackingNotifier(this.ref, this.orderId) : super(const OrderTrackingState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final order = await ref.read(orderRepositoryProvider).getById(orderId);
      state = state.copyWith(order: order, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }

    await RealtimeService.instance.connect();
    RealtimeService.instance.joinOrderRoom(orderId);
    RealtimeService.instance.onOrderStatusUpdate((data) {
      if (data['orderId'] == orderId) {
        refresh();
      }
    });
    RealtimeService.instance.onCourierLocationUpdate((data) {
      state = state.copyWith(
        courierLat: (data['latitude'] as num?)?.toDouble(),
        courierLng: (data['longitude'] as num?)?.toDouble(),
      );
    });
  }

  Future<void> refresh() async {
    try {
      final order = await ref.read(orderRepositoryProvider).getById(orderId);
      state = state.copyWith(order: order);
    } catch (_) {}
  }

  Future<void> cancel(String reason) async {
    final order = await ref.read(orderRepositoryProvider).cancel(orderId, reason: reason);
    state = state.copyWith(order: order);
  }

  @override
  void dispose() {
    RealtimeService.instance.leaveAndDisposeListeners();
    super.dispose();
  }
}

final orderTrackingProvider =
    StateNotifierProvider.family<OrderTrackingNotifier, OrderTrackingState, String>(
        (ref, orderId) => OrderTrackingNotifier(ref, orderId));
