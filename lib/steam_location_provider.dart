import 'package:demo_app/services/chat/location_service.dart';
import 'package:geolocator/geolocator.dart';

class StreamLocationProvider {
  Stream<Position?> get positionStream {
    return LocationService().getStreamLocation();
  }
}
