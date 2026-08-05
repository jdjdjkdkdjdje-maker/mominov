import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../state/cart_provider.dart';
import '../../state/restaurant_detail_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  ProductVariantModel? _selectedVariant;
  final Map<String, int> _addonQuantities = {};
  int _quantity = 1;
  final _commentController = TextEditingController();
  bool _initialized = false;

  void _initDefaults(ProductModel product) {
    if (_initialized) return;
    _initialized = true;
    if (product.variants.isNotEmpty) {
      _selectedVariant = product.variants.firstWhere((v) => v.isDefault, orElse: () => product.variants.first);
    }
  }

  List<ProductAddonModel> get _selectedAddons =>
      _addonQuantities.entries.where((e) => e.value > 0).map((e) => _addonById(e.key)).whereType<ProductAddonModel>().toList();

  ProductAddonModel? _addonById(String id) {
    return _lastProduct?.addons.firstWhere((a) => a.id == id, orElse: () => _lastProduct!.addons.first);
  }

  ProductModel? _lastProduct;

  double _computeTotal(ProductModel product) {
    double price = product.price + (_selectedVariant?.extraPrice ?? 0);
    for (final entry in _addonQuantities.entries) {
      final addon = product.addons.firstWhere((a) => a.id == entry.key, orElse: () => ProductAddonModel(id: '', name: ''));
      price += addon.price * entry.value;
    }
    return price * _quantity;
  }

  void _addToCart(ProductModel product) {
    final cart = ref.read(cartProvider.notifier);
    if (cart.belongsToDifferentRestaurant(product.restaurantId)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Yangi restoran'),
          content: const Text('Savatchada boshqa restorandan mahsulot bor. Uni tozalab, davom etamizmi?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
            TextButton(
              onPressed: () {
                cart.clear();
                Navigator.pop(context);
                _doAdd(product);
              },
              child: const Text('Tozalash va qo\'shish'),
            ),
          ],
        ),
      );
      return;
    }
    _doAdd(product);
  }

  void _doAdd(ProductModel product) {
    ref.read(cartProvider.notifier).addItem(
          product: product,
          variant: _selectedVariant,
          addons: _selectedAddons,
          addonQuantities: _addonQuantities,
          quantity: _quantity,
          comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} savatchaga qo\'shildi'), backgroundColor: AppColors.success),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final reviewsAsync = ref.watch(productReviewsProvider(widget.productId));

    return Scaffold(
      body: productAsync.when(
        loading: () => const LoadingView(),
        error: (e, st) => ErrorRetryView(
          message: e.toString(),
          onRetry: () => ref.invalidate(productDetailProvider(widget.productId)),
        ),
        data: (product) {
          _initDefaults(product);
          _lastProduct = product;
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 260,
                    flexibleSpace: FlexibleSpaceBar(
                      background: PageView(
                        children: (product.images.isEmpty ? [''] : product.images)
                            .map((url) => CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  errorWidget: (c, u, e) => Container(
                                    color: AppColors.lightBorder,
                                    child: const Icon(Icons.fastfood_rounded, size: 48, color: AppColors.lightTextSecondary),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(product.name, style: Theme.of(context).textTheme.displayMedium)),
                              RatingBadge(rating: product.rating, reviewsCount: product.reviewsCount),
                            ],
                          ),
                          const SizedBox(height: 8),
                          PriceText(price: product.price, oldPrice: product.oldPrice, fontSize: 20),
                          if (product.description != null) ...[
                            const SizedBox(height: 12),
                            Text(product.description!, style: Theme.of(context).textTheme.bodyLarge),
                          ],
                          if (product.ingredients != null || product.calories != null) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (product.calories != null)
                                  Chip(label: Text('${product.calories} kkal')),
                                if (product.ingredients != null) Chip(label: Text(product.ingredients!)),
                              ],
                            ),
                          ],
                          if (product.variants.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text('Variant tanlang', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: product.variants
                                  .map((v) => ChoiceChip(
                                        label: Text(v.extraPrice > 0 ? '${v.name} (+${formatSum(v.extraPrice)})' : v.name),
                                        selected: _selectedVariant?.id == v.id,
                                        onSelected: (_) => setState(() => _selectedVariant = v),
                                      ))
                                  .toList(),
                            ),
                          ],
                          if (product.addons.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text('Qo\'shimchalar', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            ...product.addons.map((addon) {
                              final qty = _addonQuantities[addon.id] ?? 0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text('${addon.name}  ·  ${formatSum(addon.price)}'),
                                    ),
                                    QuantityStepper(
                                      quantity: qty,
                                      size: 28,
                                      onChanged: (v) => setState(() {
                                        _addonQuantities[addon.id] = v.clamp(0, addon.maxQuantity);
                                      }),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                          const SizedBox(height: 20),
                          Text('Izoh', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _commentController,
                            maxLines: 2,
                            decoration: const InputDecoration(hintText: 'Masalan: piyozsiz bo\'lsin'),
                          ),
                          const SizedBox(height: 20),
                          SectionHeader(title: 'Sharhlar (${product.reviewsCount})'),
                          reviewsAsync.when(
                            data: (reviews) => reviews.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Text("Hozircha sharhlar yo'q"),
                                  )
                                : Column(
                                    children: reviews
                                        .take(3)
                                        .map((r) => Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 6),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(r.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                                        if (r.comment != null) Text(r.comment!),
                                                      ],
                                                    ),
                                                  ),
                                                  RatingBadge(rating: r.rating.toDouble()),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ),
                            loading: () => const LoadingView(),
                            error: (e, st) => const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))],
                  ),
                  child: Row(
                    children: [
                      QuantityStepper(quantity: _quantity, size: 40, onChanged: (v) => setState(() => _quantity = v.clamp(1, 99))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: product.isAvailable ? () => _addToCart(product) : null,
                          child: Text(
                            product.isAvailable
                                ? "Savatchaga qo'shish · ${formatSum(_computeTotal(product))}"
                                : 'Mahsulot tugagan',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
