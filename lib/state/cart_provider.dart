import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';

class CartState {
  final String? restaurantId;
  final String? restaurantName;
  final List<CartItemModel> items;
  final String? appliedPromoCode;
  final double promoDiscount;
  final double bonusToUse;

  const CartState({
    this.restaurantId,
    this.restaurantName,
    this.items = const [],
    this.appliedPromoCode,
    this.promoDiscount = 0,
    this.bonusToUse = 0,
  });

  double get subtotal => items.fold(0, (sum, i) => sum + i.totalPrice);
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    String? restaurantId,
    String? restaurantName,
    List<CartItemModel>? items,
    String? appliedPromoCode,
    double? promoDiscount,
    double? bonusToUse,
    bool clearPromo = false,
  }) =>
      CartState(
        restaurantId: restaurantId ?? this.restaurantId,
        restaurantName: restaurantName ?? this.restaurantName,
        items: items ?? this.items,
        appliedPromoCode: clearPromo ? null : (appliedPromoCode ?? this.appliedPromoCode),
        promoDiscount: clearPromo ? 0 : (promoDiscount ?? this.promoDiscount),
        bonusToUse: bonusToUse ?? this.bonusToUse,
      );
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  bool belongsToDifferentRestaurant(String restaurantId) =>
      state.restaurantId != null && state.restaurantId != restaurantId && state.items.isNotEmpty;

  void clear() => state = const CartState();

  void addItem({
    required ProductModel product,
    ProductVariantModel? variant,
    List<ProductAddonModel> addons = const [],
    Map<String, int> addonQuantities = const {},
    int quantity = 1,
    String? comment,
  }) {
    final cartItemId = CartItemModel.buildCartItemId(product.id, variant?.id, addons.map((a) => a.id).toList());
    final existingIndex = state.items.indexWhere((i) => i.cartItemId == cartItemId);
    final items = [...state.items];

    if (existingIndex >= 0) {
      items[existingIndex] = items[existingIndex].copyWith(quantity: items[existingIndex].quantity + quantity);
    } else {
      items.add(CartItemModel(
        cartItemId: cartItemId,
        product: product,
        variant: variant,
        selectedAddons: addons,
        addonQuantities: addonQuantities,
        quantity: quantity,
        comment: comment,
      ));
    }

    state = state.copyWith(
      restaurantId: product.restaurantId,
      items: items,
    );
  }

  void removeItem(String cartItemId) {
    state = state.copyWith(items: state.items.where((i) => i.cartItemId != cartItemId).toList());
  }

  void updateQuantity(String cartItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(cartItemId);
      return;
    }
    state = state.copyWith(
      items: state.items.map((i) => i.cartItemId == cartItemId ? i.copyWith(quantity: quantity) : i).toList(),
    );
  }

  void applyPromo(String code, double discount) {
    state = state.copyWith(appliedPromoCode: code, promoDiscount: discount);
  }

  void removePromo() {
    state = state.copyWith(clearPromo: true);
  }

  void setBonusToUse(double amount) {
    state = state.copyWith(bonusToUse: amount);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) => CartNotifier());
