import 'package:demo_app/services/chat/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:georouter/georouter.dart';

class GeoRoutesProvider extends ChangeNotifier {
  List<PolylinePoint> _directions = [];
  List<PolylinePoint> get directions => _directions;

  Position? _location;
  Position? get location => _location;

  double? _distance;
  double? get distance => _distance;

  Future<void> getDirections(coordinates) async {
    final List<PolylinePoint> directions =
        await LocationService().getRoute(coordinates);
    _directions = directions;
    //notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    _location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    notifyListeners();
  }

  void getDistance(firstPoint, secondPoint) {
    _distance = LocationService().getDistance(firstPoint, secondPoint);
    //notifyListeners();
  }
}
