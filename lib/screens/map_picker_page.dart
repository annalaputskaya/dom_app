import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng _currentTap = const LatLng(53.9, 27.56); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Выберите место"), 
        actions: [
          IconButton(
            icon: const Icon(Icons.check), 
            onPressed: () => Navigator.pop(context, _currentTap)
          )
        ]
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _currentTap, zoom: 12),
        onTap: (point) => setState(() => _currentTap = point),
        markers: { Marker(markerId: const MarkerId("selected"), position: _currentTap) },
      ),
    );
  }
}

