import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class YandexMapPickerPage extends StatefulWidget {
  const YandexMapPickerPage({super.key});

  @override
  State<YandexMapPickerPage> createState() => _YandexMapPickerPageState();
}

class _YandexMapPickerPageState extends State<YandexMapPickerPage> {
  late YandexMapController _mapController;

  Point _pickedLocation = const Point(
    latitude: 53.9006,
    longitude: 27.5590,
  );

  double _currentZoom = 12.0;

  final Color primaryDark = const Color(0xFF1A2238);
  final Color accentOrange = const Color(0xFFF08A08);

  // Просто возвращаем выбранные координаты на предыдущий экран
  void _confirmLocation() {
    Navigator.pop(context, _pickedLocation);
  }

  Future<void> _zoomIn() async {
    _currentZoom += 1;
    await _mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _pickedLocation,
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
          target: _pickedLocation,
          zoom: _currentZoom,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите место'),
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _confirmLocation,
            child: Text(
              'Готово',
              style: TextStyle(
                color: accentOrange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (controller) async {
              _mapController = controller;
              await _mapController.moveCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _pickedLocation,
                    zoom: _currentZoom,
                  ),
                ),
              );
            },
            onMapTap: (Point point) {
              setState(() {
                _pickedLocation = point;
              });
            },
            mapObjects: [
              PlacemarkMapObject(
                mapId: const MapObjectId('selected_location'),
                point: _pickedLocation,
                opacity: 1,
                icon: PlacemarkIcon.single(
                  PlacemarkIconStyle(
                    image: BitmapDescriptor.fromAssetImage('assets/pin.png'),
                    scale: 0.08,
                  ),
                ),
              ),
            ],
          ),
          
          // Кнопки + и -
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
          
          // Информационная панель с координатами
          Positioned(
            bottom: 20,
            left: 16,
            right: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Выбранное место",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Широта: ${_pickedLocation.latitude.toStringAsFixed(6)}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "Долгота: ${_pickedLocation.longitude.toStringAsFixed(6)}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          
          // Подсказка в центре
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Нажмите на карту,\nчтобы выбрать место",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}