import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/address_model.dart';
import '../../l10n/app_strings.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../state/address_provider.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  Future<void> _addNew(BuildContext context, WidgetRef ref) async {
    final result = await context.push<Map<String, dynamic>>('/checkout/map-picker');
    if (result == null || !context.mounted) return;

    final controller = TextEditingController(text: result['addressLine'] as String? ?? '');
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manzil nomi'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Masalan: Uy, Ish')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Saqlash')),
        ],
      ),
    );
    if (title == null) return;

    await ref.read(addressListProvider.notifier).add(AddressModel(
          id: '',
          title: title,
          addressLine: result['addressLine'] as String,
          latitude: result['latitude'] as double,
          longitude: result['longitude'] as double,
        ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('my_addresses'))),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.mango,
        onPressed: () => _addNew(context, ref),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(context.tr('add_address'), style: const TextStyle(color: Colors.white)),
      ),
      body: addressesAsync.when(
        loading: () => const LoadingView(),
        error: (e, st) => ErrorRetryView(message: e.toString(), onRetry: () => ref.read(addressListProvider.notifier).load()),
        data: (addresses) {
          if (addresses.isEmpty) {
            return EmptyStateView(
              icon: Icons.location_off_rounded,
              title: 'Manzillar yo\'q',
              subtitle: 'Tezkor buyurtma berish uchun manzil qo\'shing',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, i) {
              final a = addresses[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      a.type == AddressType.home
                          ? Icons.home_rounded
                          : a.type == AddressType.work
                              ? Icons.work_rounded
                              : Icons.location_on_rounded,
                      color: AppColors.mango,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.title ?? 'Manzil', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(a.addressLine, style: Theme.of(context).textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                      onPressed: () => ref.read(addressListProvider.notifier).remove(a.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
