import 'dart:async';
import 'dart:math';

class Coordinate {
  final double x;
  final double y;
  Coordinate(this.x, this.y);
}

/// Mock service for indoor positioning (BLE/WiFi).
class MapsService {
  final _locationController = StreamController<Coordinate>.broadcast();
  Coordinate _currentLocation = Coordinate(100.0, 150.0);
  Timer? _movementTimer;

  MapsService() {
    _startSimulatedMovement();
  }

  void _startSimulatedMovement() {
    final random = Random();
    _movementTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _currentLocation = Coordinate(
        _currentLocation.x + (random.nextDouble() * 10 - 5),
        _currentLocation.y + (random.nextDouble() * 10 - 5),
      );
      _locationController.add(_currentLocation);
    });
  }

  Stream<Coordinate> get locationStream async* {
    yield _currentLocation;
    yield* _locationController.stream;
  }

  List<Coordinate> getEvacuationRoute() {
    // Return a dummy path for turn-by-turn navigation overlay
    return [
      Coordinate(100.0, 150.0),
      Coordinate(120.0, 150.0),
      Coordinate(120.0, 200.0),
      Coordinate(200.0, 200.0), // Exit
    ];
  }

  void dispose() {
    _movementTimer?.cancel();
    _locationController.close();
  }
}
