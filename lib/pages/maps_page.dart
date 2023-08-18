import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('nearby')),
      body: FlutterMap(
        options: MapOptions(center: LatLng(51.509364, -0.128928), zoom: 10),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),
          MarkerLayer(
            markers: [
              Marker(
                  point: LatLng(51.509364, -0.128928),
                  builder: (context) {
                    return Container(color: Colors.red);
                  })
            ],
          )
        ],
      ),
    );
  }
}
