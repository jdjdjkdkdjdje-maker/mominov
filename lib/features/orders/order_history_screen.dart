import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_strings.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../state/order_provider.dart';
import 'widgets/order_list_tile.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('my_orders'))),
      body: RefreshIndicator(
        color: AppColors.mango,
        onRefresh: () async => ref.invalidate(myOrdersProvider),
        child: ordersAsync.when(
          loading: () => const LoadingView(),
          error: (e, st) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(myOrdersProvider)),
          data: (orders) {
            if (orders.isEmpty) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: EmptyStateView(
                      icon: Icons.receipt_long_rounded,
                      title: context.tr('no_orders'),
                      subtitle: "Birinchi buyurtmangizni bering va shu yerda kuzating",
                      action: ElevatedButton(onPressed: () => context.go('/'), child: const Text('Menyuga o\'tish')),
                    ),
                  ),
                ],
              );
            }
            final active = orders.where((o) => o.isActive).toList();
            final past = orders.where((o) => !o.isActive).toList();
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (active.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text('Faol buyurtmalar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                  ...active.map((o) => OrderListTile(order: o, onTap: () => context.push('/order/${o.id}'))),
                ],
                if (past.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text('Tarix', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                  ...past.map((o) => OrderListTile(order: o, onTap: () => context.push('/order/${o.id}'))),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
