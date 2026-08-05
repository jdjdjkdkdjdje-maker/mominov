import 'package:equatable/equatable.dart';
import 'product_model.dart';

class CartItemModel extends Equatable {
  final String cartItemId;
  final ProductModel product;
  final ProductVariantModel? variant;
  final List<ProductAddonModel> selectedAddons;
  final Map<String, int> addonQuantities;
  final int quantity;
  final String? comment;

  const CartItemModel({
    required this.cartItemId,
    required this.product,
    this.variant,
    this.selectedAddons = const [],
    this.addonQuantities = const {},
    this.quantity = 1,
    this.comment,
  });

  double get unitPrice {
    double price = product.price + (variant?.extraPrice ?? 0);
    for (final addon in selectedAddons) {
      final qty = addonQuantities[addon.id] ?? 1;
      price += addon.price * qty;
    }
    return price;
  }

  double get totalPrice => unitPrice * quantity;

  CartItemModel copyWith({int? quantity, String? comment}) => CartItemModel(
        cartItemId: cartItemId,
        product: product,
        variant: variant,
        selectedAddons: selectedAddons,
        addonQuantities: addonQuantities,
        quantity: quantity ?? this.quantity,
        comment: comment ?? this.comment,
      );

  Map<String, dynamic> toOrderItemJson() => {
        'productId': product.id,
        if (variant != null) 'productVariantId': variant!.id,
        'quantity': quantity,
        if (comment != null && comment!.isNotEmpty) 'comment': comment,
        if (selectedAddons.isNotEmpty)
          'addons': selectedAddons
              .map((a) => {'productAddonId': a.id, 'quantity': addonQuantities[a.id] ?? 1})
              .toList(),
      };

  static String buildCartItemId(String productId, String? variantId, List<String> addonIds) {
    final sortedAddons = [...addonIds]..sort();
    return '$productId|${variantId ?? ''}|${sortedAddons.join(',')}';
  }

  @override
  List<Object?> get props => [cartItemId, quantity, comment];
}
