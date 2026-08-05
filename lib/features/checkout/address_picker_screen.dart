import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/address_model.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../state/address_provider.dart';

class AddressPickerScreen extends ConsumerWidget {
  const AddressPickerScreen({super.key});

  Future<void> _addNew(BuildContext context, WidgetRef ref) async {
    final result = await context.push<Map<String, dynamic>>('/checkout/map-picker');
    if (result == null) return;

    final controller = TextEditingController(text: result['addressLine'] as String? ?? '');
    if (!context.mounted) return;
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manzil nomi'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Masalan: Uy, Ish")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Saqlash')),
        ],
      ),
    );
    if (title == null) return;

    final address = AddressModel(
      id: '',
      title: title,
      addressLine: result['addressLine'] as String,
      latitude: result['latitude'] as double,
      longitude: result['longitude'] as double,
    );
    final created = await ref.read(addressListProvider.notifier).add(address);
    ref.read(selectedAddressProvider.notifier).state = created;
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manzilni tanlang')),
      body: addressesAsync.when(
        loading: () => const LoadingView(),
        error: (e, st) => ErrorRetryView(message: e.toString(), onRetry: () => ref.read(addressListProvider.notifier).load()),
        data: (addresses) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            ...addresses.map((a) => ListTile(
                  leading: Icon(
                    a.type == AddressType.home
                        ? Icons.home_rounded
                        : a.type == AddressType.work
                            ? Icons.work_rounded
                            : Icons.location_on_rounded,
                    color: AppColors.mango,
                  ),
                  title: Text(a.title ?? a.addressLine),
                  subtitle: Text(a.addressLine, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    ref.read(selectedAddressProvider.notifier).state = a;
                    context.pop();
                  },
                )),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_location_alt_rounded, color: AppColors.mango),
              title: const Text('Yangi manzil qo\'shish'),
              onTap: () => _addNew(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
