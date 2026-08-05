import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/address_model.dart';
import 'repository_providers.dart';

class AddressListNotifier extends StateNotifier<AsyncValue<List<AddressModel>>> {
  final Ref ref;
  AddressListNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final list = await ref.read(addressRepositoryProvider).list();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<AddressModel> add(AddressModel address) async {
    final created = await ref.read(addressRepositoryProvider).create(address);
    await load();
    return created;
  }

  Future<void> remove(String id) async {
    await ref.read(addressRepositoryProvider).delete(id);
    await load();
  }
}

final addressListProvider =
    StateNotifierProvider<AddressListNotifier, AsyncValue<List<AddressModel>>>((ref) => AddressListNotifier(ref));

/// Checkout oqimida foydalanuvchi tanlagan yetkazib berish manzili.
final selectedAddressProvider = StateProvider<AddressModel?>((ref) => null);
