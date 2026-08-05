import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_colors.dart';

/// Xaritadan manzil tanlash (10-band: xarita, GPS).
/// Natija sifatida `{latitude, longitude, addressLine}` xaritasini qaytaradi.
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(41.311081, 69.240562); // Toshkent markazi (standart)
  String _addressLine = '';
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _useCurrentLocation();
  }

  Future<void> _useCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition();
      setState(() => _center = LatLng(position.latitude, position.longitude));
      _mapController?.animateCamera(CameraUpdate.newLatLng(_center));
      _resolveAddress(_center);
    } catch (_) {
      _resolveAddress(_center);
    }
  }

  Future<void> _resolveAddress(LatLng position) async {
    setState(() => _isResolving = true);
    try {
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() => _addressLine = [p.street, p.subLocality, p.locality].where((e) => e != null && e.isNotEmpty).join(', '));
      }
    } catch (_) {
      setState(() => _addressLine = '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}');
    } finally {
      setState(() => _isResolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manzilni xaritadan tanlang')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 15),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) => _center = position.target,
            onCameraIdle: () => _resolveAddress(_center),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          const Icon(Icons.location_pin, size: 44, color: AppColors.mango),
          Positioned(
            right: 16,
            bottom: 140,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _useCurrentLocation,
              child: const Icon(Icons.my_location_rounded, color: AppColors.ink),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_isResolving ? 'Manzil aniqlanmoqda...' : (_addressLine.isEmpty ? 'Manzil topilmadi' : _addressLine)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _isResolving
                        ? null
                        : () => context.pop({
                              'latitude': _center.latitude,
                              'longitude': _center.longitude,
                              'addressLine': _addressLine,
                            }),
                    child: const Text('Shu manzilni tanlash'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
