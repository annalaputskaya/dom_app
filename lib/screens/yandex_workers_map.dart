import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'worker_detail_page.dart'; // Добавьте этот импорт

class YandexWorkersMapPage extends StatefulWidget {
  const YandexWorkersMapPage({super.key});

  @override
  State<YandexWorkersMapPage> createState() => _YandexWorkersMapPageState();
}

class _YandexWorkersMapPageState extends State<YandexWorkersMapPage> {
  final Color primaryDark = const Color(0xFF1A2238);
  final Color accentOrange = const Color(0xFFF08A08);
  
  late YandexMapController _mapController;
  List<MapObject> _placemarks = [];
  bool _isLoading = true;
  double _currentZoom = 11.0;

  static const CameraPosition _initialPosition = CameraPosition(
    target: Point(latitude: 53.9, longitude: 27.56),
    zoom: 11,
  );

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'builder')
          .get();

      List<MapObject> placemarks = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final GeoPoint? geo = data['location'];

        if (geo != null) {
          final String name = data['name'] ?? 
              (data['firstName'] != null && data['lastName'] != null 
                  ? "${data['firstName']} ${data['lastName']}" 
                  : 'Специалист');
          final String profession = data['profession'] ?? 'Специалист';
          final String experience = data['experience'] ?? 'Не указан';
          final String? avatarBase64 = data['avatarUrl'];

          placemarks.add(
            PlacemarkMapObject(
              mapId: MapObjectId(doc.id),
              point: Point(
                latitude: geo.latitude,
                longitude: geo.longitude,
              ),
              opacity: 1,
              icon: PlacemarkIcon.single(
                PlacemarkIconStyle(
                  image: BitmapDescriptor.fromAssetImage('assets/pin.png'),
                  scale: 0.08,
                ),
              ),
              onTap: (_, __) {
                _showWorkerModal(
                  name: name,
                  profession: profession,
                  experience: experience,
                  avatarBase64: avatarBase64,
                  workerData: data, // Передаем полные данные мастера
                );
              },
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _placemarks = placemarks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e')),
        );
      }
    }
  }

  Future<void> _zoomIn() async {
    _currentZoom += 1;
    await _mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: await _getCurrentTarget(),
          zoom: _currentZoom,
        ),
      ),
    );
  }

  Future<void> _zoomOut() async {
    _currentZoom -= 1;
    await _mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: await _getCurrentTarget(),
          zoom: _currentZoom,
        ),
      ),
    );
  }

  Future<Point> _getCurrentTarget() async {
    final cameraPosition = await _mapController.getCameraPosition();
    return cameraPosition.target;
  }

  void _showWorkerModal({
    required String name,
    required String profession,
    required String experience,
    String? avatarBase64,
    required Map<String, dynamic> workerData,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        ImageProvider? avatar;
        if (avatarBase64 != null && avatarBase64.isNotEmpty) {
          try {
            avatar = MemoryImage(base64Decode(avatarBase64));
          } catch (_) {}
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 38,
                backgroundImage: avatar,
                child: avatar == null
                    ? Icon(Icons.person, size: 40, color: Colors.grey.shade400)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.work, color: accentOrange, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      profession,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.timeline, color: accentOrange, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Опыт: $experience',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // Закрываем модальное окно
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Закрыть'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Закрываем модальное окно
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkerDetailPage(workerData: workerData),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Подробнее'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Мастера на карте"),
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWorkers,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_placemarks.isEmpty)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Нет мастеров с указанным местоположением",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            YandexMap(
              mapObjects: _placemarks,
              onMapCreated: (YandexMapController controller) async {
                _mapController = controller;
                await _mapController.moveCamera(
                  CameraUpdate.newCameraPosition(_initialPosition),
                );
              },
            ),
          
          Positioned(
            bottom: 20,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.black87, size: 28),
                    onPressed: _zoomIn,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove, color: Colors.black87, size: 28),
                    onPressed: _zoomOut,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}