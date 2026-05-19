import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'worker_detail_page.dart'; // Импорт страницы деталей

class WorkersMapPage extends StatefulWidget {
  const WorkersMapPage({super.key});

  @override
  State<WorkersMapPage> createState() => _WorkersMapPageState();
}

class _WorkersMapPageState extends State<WorkersMapPage> {
  final Color primaryDark = const Color(0xFF1A2238);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Мастера на карте"),
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'builder')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          Set<Marker> markers = {};
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final GeoPoint? geo = data['location'];
            
            if (geo != null) {
              markers.add(
                Marker(
                  markerId: MarkerId(doc.id),
                  position: LatLng(geo.latitude, geo.longitude),
                  infoWindow: InfoWindow(
                    title: "${data['name']} (${data['specialty']})",
                    snippet: "Опыт: ${data['experience']}. Нажмите для профиля",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkerDetailPage(workerData: data),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          }
          return GoogleMap(
            initialCameraPosition: const CameraPosition(target: LatLng(53.9, 27.56), zoom: 11),
            markers: markers,
            myLocationEnabled: true,
          );
        },
      ),
    );
  }
}
