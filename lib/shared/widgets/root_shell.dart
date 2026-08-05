import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../state/cart_provider.dart';

class RootShell extends ConsumerWidget {
  final Widget child;
  const RootShell({super.key, required this.child});

  int _indexFor(String location) {
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/orders')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _indexFor(location);
    final cartCount = ref.watch(cartProvider.select((c) => c.itemCount));

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/search');
              break;
            case 2:
              context.go('/orders');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Asosiy'),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Qidiruv'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Buyurtmalar'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
      floatingActionButton: cartCount > 0
          ? badges.Badge(
              badgeContent: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 11)),
              badgeStyle: const badges.BadgeStyle(badgeColor: AppColors.ink),
              position: badges.BadgePosition.topEnd(top: -6, end: -6),
              child: FloatingActionButton(
                backgroundColor: AppColors.mango,
                onPressed: () => context.push('/cart'),
                child: const Icon(Icons.shopping_bag_rounded, color: Colors.white),
              ),
            )
          : null,
    );
  }
}
