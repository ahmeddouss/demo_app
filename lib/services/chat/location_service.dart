import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:georouter/georouter.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  Position? _location;
  Position? get location => _location;
  double speedMps = 0.0;
  Position? currentPosition;
  Stream<Position?> getStreamLocation() {
    return Geolocator.getPositionStream();
  }

  Future<void> getCurrentLocation() async {
    _location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<Position> getCurrentLocations() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  double getDistance(LatLng firstPoint, LatLng secondPoint) {
    return Geolocator.distanceBetween(firstPoint.latitude, firstPoint.longitude,
        secondPoint.latitude, secondPoint.longitude);
  }

  Future<List<PolylinePoint>> getRoute(List<PolylinePoint> coordinates) async {
    final georouter = GeoRouter(mode: TravelMode.driving);
    return await georouter.getDirectionsBetweenPoints(coordinates);
  }
}
