import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../state/cart_provider.dart';
import 'widgets/cart_item_tile.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _promoController = TextEditingController();

  void _applyPromo() {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;
    // Eslatma: haqiqiy loyihada promo kod backend orqali tekshiriladi
    // (PromoCodeRepository) — bu yerda checkout bosqichida yakuniy
    // hisob-kitob serverda amalga oshadi.
    ref.read(cartProvider.notifier).applyPromo(code, 0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Promo kod buyurtma berishda tekshiriladi")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Savatcha')),
      body: cart.isEmpty
          ? EmptyStateView(
              icon: Icons.shopping_bag_outlined,
              title: "Savatcha bo'sh",
              subtitle: "Sevimli taomlaringizni tanlab, savatchaga qo'shing",
              action: ElevatedButton(onPressed: () => context.go('/'), child: const Text('Menyuga qaytish')),
            )
          : Column(
              children: [
                if (cart.restaurantName != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront_rounded, size: 18, color: AppColors.mango),
                        const SizedBox(width: 6),
                        Text(cart.restaurantName!, style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 4),
                    itemCount: cart.items.length,
                    itemBuilder: (context, i) {
                      final item = cart.items[i];
                      return CartItemTile(
                        item: item,
                        onQuantityChanged: (q) => ref.read(cartProvider.notifier).updateQuantity(item.cartItemId, q),
                        onRemove: () => ref.read(cartProvider.notifier).removeItem(item.cartItemId),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _promoController,
                              decoration: const InputDecoration(hintText: 'Promo kod', prefixIcon: Icon(Icons.local_offer_rounded)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(onPressed: _applyPromo, child: const Text("Qo'llash")),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Mahsulotlar (${cart.itemCount})', style: Theme.of(context).textTheme.bodyMedium),
                          Text(formatSum(cart.subtotal)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => context.push('/checkout'),
                        child: Text('Buyurtma berish · ${formatSum(cart.subtotal)}'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
