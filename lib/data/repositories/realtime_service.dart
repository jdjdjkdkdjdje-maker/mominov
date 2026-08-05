import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/constants/app_config.dart';
import '../../core/storage/secure_storage.dart';

class RealtimeService {
  RealtimeService._();
  static final RealtimeService instance = RealtimeService._();

  io.Socket? _socket;

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;
    final token = await SecureStorage.instance.accessToken;

    _socket = io.io(
      '${AppConfig.socketUrl}/realtime',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );
  }

  void joinOrderRoom(String orderId) {
    _socket?.emit('joinOrderRoom', orderId);
  }

  void onOrderStatusUpdate(void Function(Map<String, dynamic>) callback) {
    _socket?.on('orderStatusUpdate', (data) => callback(Map<String, dynamic>.from(data)));
  }

  void onCourierLocationUpdate(void Function(Map<String, dynamic>) callback) {
    _socket?.on('courierLocationUpdate', (data) => callback(Map<String, dynamic>.from(data)));
  }

  void leaveAndDisposeListeners() {
    _socket?.off('orderStatusUpdate');
    _socket?.off('courierLocationUpdate');
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
