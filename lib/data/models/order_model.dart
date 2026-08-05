enum OrderStatus {
  created,
  acceptedByRestaurant,
  preparing,
  readyForPickup,
  courierAssigned,
  pickedUp,
  onTheWay,
  delivered,
  cancelledByCustomer,
  cancelledByRestaurant,
  rejected,
}

enum OrderType { delivery, pickup, scheduled }

OrderStatus orderStatusFromString(String value) {
  return OrderStatus.values.firstWhere(
    (e) => e.name.toLowerCase() == _camelKey(value),
    orElse: () => OrderStatus.created,
  );
}

String _camelKey(String snake) {
  final parts = snake.split('_');
  return parts.first + parts.skip(1).map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1)).join();
}

OrderType orderTypeFromString(String? value) {
  switch (value) {
    case 'pickup':
      return OrderType.pickup;
    case 'scheduled':
      return OrderType.scheduled;
    default:
      return OrderType.delivery;
  }
}

const List<OrderStatus> orderStatusTimeline = [
  OrderStatus.created,
  OrderStatus.acceptedByRestaurant,
  OrderStatus.preparing,
  OrderStatus.readyForPickup,
  OrderStatus.courierAssigned,
  OrderStatus.onTheWay,
  OrderStatus.delivered,
];

class OrderItemAddonModel {
  final String name;
  final double price;
  final int quantity;

  OrderItemAddonModel({required this.name, required this.price, this.quantity = 1});

  factory OrderItemAddonModel.fromJson(Map<String, dynamic> json) => OrderItemAddonModel(
        name: json['name'] as String? ?? (json['addon']?['name'] as String? ?? ''),
        price: (json['price'] as num?)?.toDouble() ?? 0,
        quantity: json['quantity'] as int? ?? 1,
      );
}

class OrderItemModel {
  final String id;
  final String productId;
  final String productName;
  final String? variantName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? comment;
  final List<OrderItemAddonModel> addons;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.variantName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.comment,
    this.addons = const [],
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        id: json['id'] as String,
        productId: json['productId'] as String? ?? '',
        productName: (json['product']?['name'] as String?) ?? '',
        variantName: json['productVariant']?['name'] as String?,
        quantity: json['quantity'] as int? ?? 1,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
        totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
        comment: json['comment'] as String?,
        addons: ((json['addons'] as List?) ?? [])
            .map((e) => OrderItemAddonModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String restaurantId;
  final String? restaurantName;
  final String? restaurantLogoUrl;
  final String? courierId;
  final String? courierName;
  final String? courierPhone;
  final OrderType orderType;
  final OrderStatus status;
  final double subtotal;
  final double deliveryFee;
  final double discountAmount;
  final double bonusUsed;
  final double totalAmount;
  final DateTime? scheduledAt;
  final String? customerComment;
  final String? cancellationReason;
  final DateTime? estimatedDeliveryAt;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.restaurantId,
    this.restaurantName,
    this.restaurantLogoUrl,
    this.courierId,
    this.courierName,
    this.courierPhone,
    this.orderType = OrderType.delivery,
    required this.status,
    required this.subtotal,
    this.deliveryFee = 0,
    this.discountAmount = 0,
    this.bonusUsed = 0,
    required this.totalAmount,
    this.scheduledAt,
    this.customerComment,
    this.cancellationReason,
    this.estimatedDeliveryAt,
    required this.createdAt,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String,
        orderNumber: json['orderNumber'] as String? ?? '',
        restaurantId: json['restaurantId'] as String? ?? '',
        restaurantName: json['restaurant']?['name'] as String?,
        restaurantLogoUrl: json['restaurant']?['logoUrl'] as String?,
        courierId: json['courierId'] as String?,
        courierName: json['courier']?['user']?['fullName'] as String?,
        courierPhone: json['courier']?['user']?['phoneNumber'] as String?,
        orderType: orderTypeFromString(json['orderType'] as String?),
        status: orderStatusFromString(json['status'] as String? ?? 'created'),
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
        deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
        discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
        bonusUsed: (json['bonusUsed'] as num?)?.toDouble() ?? 0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
        scheduledAt: json['scheduledAt'] != null ? DateTime.tryParse(json['scheduledAt']) : null,
        customerComment: json['customerComment'] as String?,
        cancellationReason: json['cancellationReason'] as String?,
        estimatedDeliveryAt:
            json['estimatedDeliveryAt'] != null ? DateTime.tryParse(json['estimatedDeliveryAt']) : null,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        items: ((json['items'] as List?) ?? [])
            .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  bool get isActive => ![
        OrderStatus.delivered,
        OrderStatus.cancelledByCustomer,
        OrderStatus.cancelledByRestaurant,
        OrderStatus.rejected,
      ].contains(status);

  bool get isCancelled =>
      status == OrderStatus.cancelledByCustomer || status == OrderStatus.cancelledByRestaurant || status == OrderStatus.rejected;
}
