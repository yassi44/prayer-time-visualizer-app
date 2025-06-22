
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

final locationServiceProvider = Provider((ref) => LocationService());

class LocationService {
  Position? _currentPosition;
  
  Position? get getCurrentPosition => _currentPosition;
  
  Future<Position> getCurrentLocation() async {
    if (_currentPosition != null) {
      return _currentPosition!;
    }
    
    // Check permissions
    var permission = await Permission.location.status;
    if (permission.isDenied) {
      permission = await Permission.location.request();
    }
    
    if (permission.isGranted) {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return _currentPosition!;
    } else {
      // Default to a location if permission denied (you might want to show an error)
      _currentPosition = Position(
        latitude: 23.9088,
        longitude: 89.1220,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      return _currentPosition!;
    }
  }
}
