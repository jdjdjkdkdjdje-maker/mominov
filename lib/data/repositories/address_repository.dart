import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/address_model.dart';

class AddressRepository {
  final ApiClient _client = ApiClient.instance;

  Future<List<AddressModel>> list() async {
    final res = await _client.getList(ApiEndpoints.addresses);
    return res.map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AddressModel> create(AddressModel address) async {
    final res = await _client.post(ApiEndpoints.addresses, data: address.toCreateJson());
    return AddressModel.fromJson(res);
  }

  Future<AddressModel> update(String id, AddressModel address) async {
    final res = await _client.patch(ApiEndpoints.address(id), data: address.toCreateJson());
    return AddressModel.fromJson(res);
  }

  Future<void> delete(String id) => _client.delete(ApiEndpoints.address(id));
}
