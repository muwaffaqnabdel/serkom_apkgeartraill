import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/providers/location_service.dart';

/// NearbyStoresView — halaman daftar toko/bengkel sepeda terdekat
/// Menggunakan GPS untuk menghitung jarak ke setiap toko
class NearbyStoresView extends StatelessWidget {
  const NearbyStoresView({super.key});

  // Data toko/bengkel sepeda terdekat (simulasi database toko)
  static final List<Map<String, dynamic>> _storeDatabase = [
    {
      'id': 'store-1',
      'name': 'Gear & Trail — Pusat Jakarta',
      'type': 'Toko Resmi',
      'address': 'Jl. Sudirman No. 45, Jakarta Pusat',
      'phone': '021-5551234',
      'hours': 'Senin-Sabtu: 09.00-20.00',
      'lat': -6.2088,
      'lng': 106.8456,
      'services': ['Jual Sepeda', 'Servis', 'Spare Part'],
      'icon': Icons.store,
      'color': Color(0xFF1E3A2F),
    },
    {
      'id': 'store-2',
      'name': 'Bengkel MTB Cilandak',
      'type': 'Bengkel Mitra',
      'address': 'Jl. Cilandak Tengah No. 12, Jakarta Selatan',
      'phone': '021-5557890',
      'hours': 'Senin-Minggu: 08.00-18.00',
      'lat': -6.2896,
      'lng': 106.8060,
      'services': ['Servis', 'Tune-Up', 'Ganti Ban'],
      'icon': Icons.build_outlined,
      'color': Color(0xFFEA580C),
    },
    {
      'id': 'store-3',
      'name': 'Gear & Trail — Bandung',
      'type': 'Toko Resmi',
      'address': 'Jl. Asia Afrika No. 78, Bandung',
      'phone': '022-4201234',
      'hours': 'Senin-Minggu: 10.00-21.00',
      'lat': -6.9218,
      'lng': 107.6077,
      'services': ['Jual Sepeda', 'Servis', 'Aksesori', 'Spare Part'],
      'icon': Icons.store,
      'color': Color(0xFF1E3A2F),
    },
    {
      'id': 'store-4',
      'name': 'Trail Bike Shop Bogor',
      'type': 'Mitra Terdaftar',
      'address': 'Jl. Juanda No. 23, Bogor',
      'phone': '0251-8321234',
      'hours': 'Senin-Sabtu: 09.00-17.00',
      'lat': -6.5971,
      'lng': 106.8060,
      'services': ['Jual Sepeda', 'Servis', 'Spare Part'],
      'icon': Icons.pedal_bike_outlined,
      'color': Color(0xFF047857),
    },
    {
      'id': 'store-5',
      'name': 'Bengkel Sepeda Kebayoran',
      'type': 'Bengkel Mitra',
      'address': 'Jl. Melawai No. 8, Kebayoran Baru, Jakarta',
      'phone': '021-7201234',
      'hours': 'Senin-Sabtu: 08.30-17.30',
      'lat': -6.2466,
      'lng': 106.7954,
      'services': ['Servis', 'Ganti Komponen', 'Tune-Up'],
      'icon': Icons.build_outlined,
      'color': Color(0xFFEA580C),
    },
    {
      'id': 'store-6',
      'name': 'MTB Store Depok',
      'type': 'Mitra Terdaftar',
      'address': 'Jl. Margonda Raya No. 100, Depok',
      'phone': '021-7771234',
      'hours': 'Senin-Minggu: 09.00-20.00',
      'lat': -6.4025,
      'lng': 106.7942,
      'services': ['Jual Sepeda', 'Aksesori', 'Helm & Protektor'],
      'icon': Icons.directions_bike,
      'color': Color(0xFF1E3A2F),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final LocationService locationService = Get.find<LocationService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E3A2F), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Toko & Bengkel Terdekat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A2F),
            fontSize: 18,
          ),
        ),
        actions: [
          Obx(() => locationService.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF1E3A2F),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.my_location, color: Color(0xFF1E3A2F)),
                  onPressed: () => _detectLocation(locationService),
                  tooltip: 'Deteksi Lokasi',
                )),
        ],
      ),
      body: Column(
        children: [
          // Location status banner
          Obx(() {
            final pos = locationService.currentPosition.value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: pos != null ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
              child: Row(
                children: [
                  Icon(
                    pos != null ? Icons.location_on : Icons.location_searching,
                    color: pos != null ? const Color(0xFF047857) : const Color(0xFFB45309),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      pos != null
                          ? 'Lokasi Anda: ${locationService.generateAddressFromCoords(pos.latitude, pos.longitude)}\n${locationService.formatCoordinates(pos)}'
                          : 'Tekan tombol 📍 di atas untuk mendeteksi lokasi Anda\nJarak toko dihitung dari posisi GPS Anda',
                      style: TextStyle(
                        fontSize: 12,
                        color: pos != null ? const Color(0xFF047857) : const Color(0xFFB45309),
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (pos == null)
                    TextButton(
                      onPressed: () => _detectLocation(locationService),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF1E3A2F),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('Deteksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                ],
              ),
            );
          }),

          // Stores list
          Expanded(
            child: Obx(() {
              final pos = locationService.currentPosition.value;
              final stores = _getSortedStores(pos, locationService);
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: stores.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildStoreCard(stores[index], context),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() => locationService.isLoading.value
          ? const SizedBox.shrink()
          : FloatingActionButton.extended(
              onPressed: () => _detectLocation(locationService),
              backgroundColor: const Color(0xFF1E3A2F),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.near_me),
              label: const Text('Cari Terdekat', style: TextStyle(fontWeight: FontWeight.bold)),
            )),
    );
  }

  List<Map<String, dynamic>> _getSortedStores(Position? pos, LocationService service) {
    final stores = List<Map<String, dynamic>>.from(_storeDatabase);
    if (pos != null) {
      for (final store in stores) {
        store['distance'] = service.calculateDistance(
          pos.latitude, pos.longitude,
          store['lat'] as double, store['lng'] as double,
        );
      }
      stores.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    }
    return stores;
  }

  Widget _buildStoreCard(Map<String, dynamic> store, BuildContext context) {
    final distance = store['distance'] as double?;
    final services = store['services'] as List<String>;
    final color = store['color'] as Color;

    return GestureDetector(
      onTap: () => _showStoreDetail(store, context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(store['icon'] as IconData, color: color, size: 24),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          store['name'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      if (distance != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: distance < 5
                                ? const Color(0xFFECFDF5)
                                : distance < 20
                                    ? const Color(0xFFFFFBEB)
                                    : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            distance < 1
                                ? '${(distance * 1000).toInt()} m'
                                : '${distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: distance < 5
                                  ? const Color(0xFF047857)
                                  : distance < 20
                                      ? const Color(0xFFB45309)
                                      : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      store['type'] as String,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          store['address'] as String,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        store['hours'] as String,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Service chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: services.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(s, style: const TextStyle(fontSize: 10, color: Color(0xFF475569))),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStoreDetail(Map<String, dynamic> store, BuildContext context) {
    final distance = store['distance'] as double?;
    final services = store['services'] as List<String>;
    final color = store['color'] as Color;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(store['icon'] as IconData, color: color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store['name'] as String,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A2F)),
                      ),
                      Text(store['type'] as String, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
              ],
            ),
            const SizedBox(height: 20),

            if (distance != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.near_me, color: Color(0xFF047857), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      distance < 1
                          ? 'Jarak: ${(distance * 1000).toInt()} meter dari lokasi Anda'
                          : 'Jarak: ${distance.toStringAsFixed(2)} km dari lokasi Anda',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                    ),
                  ],
                ),
              ),
            if (distance != null) const SizedBox(height: 16),

            _buildDetailRow(Icons.location_on_outlined, 'Alamat', store['address'] as String),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.phone_outlined, 'Telepon', store['phone'] as String),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.access_time, 'Jam Buka', store['hours'] as String),
            const SizedBox(height: 16),

            const Text('Layanan Tersedia:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E3A2F))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: services.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(s, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              )).toList(),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A2F),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Future<void> _detectLocation(LocationService service) async {
    await service.getCurrentPosition();
  }
}
