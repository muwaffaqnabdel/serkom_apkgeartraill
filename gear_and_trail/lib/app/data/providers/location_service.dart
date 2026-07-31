import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// LocationService — mengelola GPS, deteksi lokasi user, dan pencarian data real toko & bengkel sepeda
class LocationService extends GetxController {
  final isLoading = false.obs;
  final currentPosition = Rxn<Position>();
  final currentAddress = ''.obs;
  final permissionStatus = ''.obs;

  final realStoresList = <Map<String, dynamic>>[].obs;
  final isFetchingRealStores = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    if (kIsWeb) {
      permissionStatus.value = 'web';
      return;
    }
    try {
      final permission = await Geolocator.checkPermission();
      permissionStatus.value = permission.name;
    } catch (e) {
      debugPrint('LocationService: Error checking permission: $e');
    }
  }

  /// Minta izin lokasi dari user
  Future<bool> requestPermission() async {
    if (kIsWeb) return true; // Web handles permission natively in browser

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        permissionStatus.value = 'deniedForever';
        Get.snackbar(
          'Akses Lokasi Diblokir',
          'Aktifkan izin lokasi di pengaturan HP untuk menggunakan fitur ini.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFDC2626),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          mainButton: TextButton(
            onPressed: () => Geolocator.openAppSettings(),
            child: const Text('Buka Pengaturan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
        return false;
      }

      if (permission == LocationPermission.denied) {
        permissionStatus.value = 'denied';
        Get.snackbar(
          'Izin Lokasi Ditolak',
          'Izin akses lokasi diperlukan untuk fitur ini.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEA580C),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }

      permissionStatus.value = permission.name;
      return true;
    } catch (e) {
      debugPrint('LocationService: Error requesting permission: $e');
      return false;
    }
  }

  /// Dapatkan posisi GPS saat ini
  Future<Position?> getCurrentPosition() async {
    isLoading.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'GPS Tidak Aktif',
          'Aktifkan GPS/Lokasi di pengaturan perangkat Anda.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEA580C),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        isLoading.value = false;
        return null;
      }

      final hasPermission = await requestPermission();
      if (!hasPermission) {
        isLoading.value = false;
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      currentPosition.value = position;

      // Ambil data real toko/bengkel sepeda terdekat secara otomatis berdasarkan GPS
      fetchRealNearbyBikeStores(position.latitude, position.longitude);

      return position;
    } catch (e) {
      debugPrint('LocationService: Error getting position: $e');
      Get.snackbar(
        'Gagal Mendapatkan Lokasi',
        'Tidak dapat mendeteksi lokasi. Coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Ambil data REAL toko & bengkel sepeda global terdekat dari OpenStreetMap API
  Future<List<Map<String, dynamic>>> fetchRealNearbyBikeStores(double lat, double lng) async {
    isFetchingRealStores.value = true;
    List<Map<String, dynamic>> results = [];

    try {
      final query = '''
[out:json][timeout:15];
(
  node["shop"="bicycle"](around:25000,$lat,$lng);
  way["shop"="bicycle"](around:25000,$lat,$lng);
  node["craft"="bicycle_repair"](around:25000,$lat,$lng);
  node["amenity"="bicycle_repair_station"](around:25000,$lat,$lng);
);
out center 30;
''';
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: query,
        headers: {'User-Agent': 'GearAndTrailApp/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List? ?? [];

        for (var el in elements) {
          final tags = el['tags'] as Map<String, dynamic>? ?? {};
          final name = tags['name'] as String? ?? tags['brand'] as String? ?? 'Bengkel Sepeda';
          
          double? itemLat;
          double? itemLng;
          if (el['type'] == 'node') {
            itemLat = (el['lat'] as num?)?.toDouble();
            itemLng = (el['lon'] as num?)?.toDouble();
          } else if (el['center'] != null) {
            itemLat = (el['center']['lat'] as num?)?.toDouble();
            itemLng = (el['center']['lon'] as num?)?.toDouble();
          }

          if (itemLat != null && itemLng != null) {
            final dist = calculateDistance(lat, lng, itemLat, itemLng);
            final street = tags['addr:street'] ?? tags['addr:full'] ?? tags['address'] ?? '';
            final city = tags['addr:city'] ?? tags['addr:suburb'] ?? '';
            String address = [street, city].where((s) => s.toString().isNotEmpty).join(', ');
            if (address.isEmpty) {
              address = 'Area GPS: ${itemLat.toStringAsFixed(4)}, ${itemLng.toStringAsFixed(4)}';
            }

            final isRepairOnly = tags['craft'] == 'bicycle_repair' || tags['amenity'] == 'bicycle_repair_station';
            final type = isRepairOnly ? 'Bengkel Sepeda Global' : 'Toko & Servis Sepeda';
            final phone = tags['phone'] ?? tags['contact:phone'] ?? '-';
            final openingHours = tags['opening_hours'] ?? 'Senin-Sabtu: 08.00-17.00';

            results.add({
              'id': 'osm-${el['id']}',
              'name': name,
              'type': type,
              'address': address,
              'phone': phone.toString(),
              'hours': openingHours.toString(),
              'lat': itemLat,
              'lng': itemLng,
              'distance': dist,
              'services': isRepairOnly ? ['Servis Sepeda', 'Tune-Up', 'Ganti Ban'] : ['Toko Sepeda', 'Servis Sepeda', 'Spare Part'],
              'icon': isRepairOnly ? Icons.build_outlined : Icons.store,
              'color': isRepairOnly ? const Color(0xFFEA580C) : const Color(0xFF1E3A2F),
              'isRealOSMData': true,
            });
          }
        }
      }
    } catch (e) {
      debugPrint('LocationService: Overpass API error: $e');
    }

    // Fallback: Jika Overpass belum mendapatkan node, gunakan Nominatim Search API
    if (results.isEmpty) {
      try {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=bengkel+sepeda&lat=$lat&lon=$lng&bounded=1&viewbox=${lng - 0.4},${lat + 0.4},${lng + 0.4},${lat - 0.4}&limit=15'
        );
        final response = await http.get(url, headers: {
          'User-Agent': 'GearAndTrailApp/1.0 (contact@geartrail.app)'
        }).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final list = json.decode(response.body) as List? ?? [];
          for (var item in list) {
            final itemLat = double.tryParse(item['lat'].toString());
            final itemLng = double.tryParse(item['lon'].toString());
            if (itemLat != null && itemLng != null) {
              final dist = calculateDistance(lat, lng, itemLat, itemLng);
              final displayName = item['display_name'].toString();
              final name = item['name'] ?? displayName.split(',').first;

              results.add({
                'id': 'nominatim-${item['place_id']}',
                'name': name,
                'type': 'Bengkel Sepeda Global',
                'address': displayName,
                'phone': '-',
                'hours': 'Senin-Sabtu: 08.30-17.00',
                'lat': itemLat,
                'lng': itemLng,
                'distance': dist,
                'services': ['Servis Sepeda', 'Spare Part', 'Tune-Up'],
                'icon': Icons.build_outlined,
                'color': const Color(0xFFEA580C),
                'isRealOSMData': true,
              });
            }
          }
        }
      } catch (e) {
        debugPrint('LocationService: Nominatim API error: $e');
      }
    }

    results.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    realStoresList.assignAll(results);
    isFetchingRealStores.value = false;
    return results;
  }

  /// Hitung jarak antara dua koordinat dalam kilometer
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Format koordinat jadi string yang readable
  String formatCoordinates(Position position) {
    final lat = position.latitude.toStringAsFixed(4);
    final lon = position.longitude.toStringAsFixed(4);
    return 'Lat: $lat, Lon: $lon';
  }

  /// Generate alamat estimasi dari koordinat
  String generateAddressFromCoords(double lat, double lon) {
    if (lat >= -6.4 && lat <= -6.0 && lon >= 106.6 && lon <= 107.0) {
      return 'Jakarta, DKI Jakarta';
    } else if (lat >= -7.1 && lat <= -6.8 && lon >= 107.5 && lon <= 107.8) {
      return 'Bandung, Jawa Barat';
    } else if (lat >= -6.7 && lat <= -6.5 && lon >= 106.7 && lon <= 106.9) {
      return 'Bogor, Jawa Barat';
    } else if (lat >= -6.5 && lat <= -6.3 && lon >= 106.7 && lon <= 106.9) {
      return 'Depok, Jawa Barat';
    } else if (lat >= -7.3 && lat <= -7.0 && lon >= 112.6 && lon <= 112.8) {
      return 'Surabaya, Jawa Timur';
    } else if (lat >= -7.9 && lat <= -7.7 && lon >= 110.3 && lon <= 110.5) {
      return 'Yogyakarta, DIY';
    } else if (lat >= -8.7 && lat <= -8.6 && lon >= 115.1 && lon <= 115.3) {
      return 'Denpasar, Bali';
    } else {
      return 'Area (${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)})';
    }
  }
}
