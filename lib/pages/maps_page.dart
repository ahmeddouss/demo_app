import 'package:demo_app/services/chat/location_service.dart';
import 'package:demo_app/steam_location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:georouter/georouter.dart';
import 'package:demo_app/georoutes_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

void main() {
  runApp(MaterialApp(
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GeoRoutesProvider()),
        StreamProvider<Position?>(
            create: (context) => StreamLocationProvider().positionStream,
            initialData: Position(
                latitude: 36.805483,
                longitude: 10.239920,
                timestamp: DateTime.now(),
                accuracy: 0,
                altitude: 0,
                heading: 0,
                speed: 0,
                speedAccuracy: 0,
                headingAccuracy: 0.0,
                altitudeAccuracy: 0.0)),
      ],
      child: MapsPage(),
    ),
  ));
}

class _MapsPageState extends State<MapsPage> {
  bool liveMode = false;
  late LatLng livePosition;
  LatLng? location;
  double distanceRest = 0;
  LatLng target = LatLng(36.770497, 10.197432);
  List<LatLng> polylineCoordinates = [];
  double distance = 0;
  double speedMps = 0.0;
  Stopwatch? stopwatch;

  Timer? timer; // Declare a Timer
  Future<void> getLocation() async {
    Position locationService = await LocationService().getCurrentLocations();
    location = LatLng(locationService.latitude, locationService.longitude);
    setState(() {
      location;
    });
  }

  Future<void> getDirectionDistance(location, target) async {
    List<PolylinePoint> _coordinates = [
      PolylinePoint(
          latitude: location!.latitude,
          longitude: location!.longitude), // London, UK
      PolylinePoint(
          latitude: target!.latitude,
          longitude: target!.longitude), // Paris, France
    ];
    List<PolylinePoint> direction =
        await LocationService().getRoute(_coordinates);
    distance = LocationService().getDistance(location, target);
    polylineCoordinates = direction.map((point) {
      return LatLng(point.latitude, point.longitude);
    }).toList();

    setState(() {
      polylineCoordinates;
      distance;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize the geolocator and start listening to the position stream
    getLocation();
    stopwatch = Stopwatch()..start(); // Initialize and start the stopwatch

    // Create a Timer to update the UI every second
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (liveMode) {
        setState(() {}); // Update the UI
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = _formatTime(stopwatch!.elapsed);
    return Scaffold(
        appBar: AppBar(title: const Text('Nearby')),
        body: liveMode ? liveMaps(formattedTime) : mapsFix(formattedTime),
        floatingActionButton: !liveMode
            ? FloatingActionButton(
                onPressed: () {
                  getLocation();
                  if (polylineCoordinates.isNotEmpty) {
                    getDirectionDistance(location, target);
                  }
                },
                child: const Icon(Icons.location_on),
              )
            : null);
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget mapsFix(formattedTime) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            center: LatLng(36.805483, 10.239920),
            zoom: 10,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayerOptions(markers: [
              if (location != null)
                Marker(
                    point: location!,
                    builder: (context) {
                      return const Icon(
                        Icons.circle,
                        color: Colors.blue,
                        size: 30.0,
                      );
                    })
            ]),
            PolylineLayerOptions(polylines: [
              if (polylineCoordinates.isNotEmpty)
                Polyline(
                  points: polylineCoordinates,
                  color: Colors.blue,
                  strokeWidth: 4.0,
                )
            ])
          ],
        ),
        Positioned(
          bottom: 16.0,
          left: 16.0,
          right: 90.0,
          child: Card(
            elevation: 4.0,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (distance != 0)
                      Text(
                        'Distance : $distance m',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            liveMode = true;
                            stopwatch!.start();
                          });
                        },
                        child: Text("start")),
                    ElevatedButton(
                        onPressed: () {
                          getDirectionDistance(location, target);
                        },
                        child: Text("getRoute"))
                  ],
                )),
          ),
        ),
      ],
    );
  }

  Widget liveMaps(formattedTime) {
    return Stack(children: [
      Consumer2<GeoRoutesProvider, Position?>(
          builder: (context, directions, positionStream, child) {
        speedMps = positionStream!.speed;

        livePosition =
            LatLng(positionStream.latitude, positionStream.longitude);
        distanceRest = LocationService()
            .getDistance(livePosition, LatLng(36.770497, 10.197432));
        return FlutterMap(
          options: MapOptions(
            center: LatLng(36.805483, 10.239920),
            zoom: 10,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayerOptions(markers: [
              Marker(
                point: livePosition,
                builder: (context) {
                  return const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40.0,
                  );
                },
              ),
            ]),
            PolylineLayerOptions(polylines: [
              Polyline(
                points: polylineCoordinates,
                color: Colors.blue,
                strokeWidth: 4.0,
              )
            ])
          ],
        );
      }),
      Positioned(
        bottom: 16.0,
        left: 16.0,
        right: 16.0,
        child: Card(
          elevation: 4.0,
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer2<GeoRoutesProvider, Position?>(
                  builder: (context, directions, positionStream, child) {
                return Column(
                  children: [
                    Text(
                      'Distance : ${distanceRest.toString()}m',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Speed :${speedMps.toStringAsFixed(2)} m/s',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      'Time: $formattedTime', // Use formattedTime here
                      style: TextStyle(fontSize: 40.0),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            liveMode = false;

                            stopwatch!.reset();
                            //stopwatch!.stop();
                          });
                        },
                        child: const Icon(Icons.stop))
                  ],
                );
              })),
        ),
      ),
    ]);
  }
}
