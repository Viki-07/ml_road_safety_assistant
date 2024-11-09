import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class CrashFunction {
  final Duration ignoreDuration;
  DateTime? _userAccelerometerUpdateTime;

  CrashFunction({required this.ignoreDuration});
  
  StreamSubscription<UserAccelerometerEvent> listenToAccelerometerEvents({
    required Stream<UserAccelerometerEvent> userAccelerometerEventStream,
    required double threshold,
    required Function(double gForce) onGForceUpdate,
    required Function onThresholdExceeded,
    required Function(String errorMessage) onError,
  }) {
    return userAccelerometerEventStream.listen(
      (UserAccelerometerEvent event) {
        final now = DateTime.now();  // Using DateTime.now() for time calculations

        if (_userAccelerometerUpdateTime == null || now.difference(_userAccelerometerUpdateTime!) > ignoreDuration) {
          // Calculate G-force
          final gForce = calculateGForce(event.x, event.y, event.z);

          // Notify the main widget about the updated G-force
          onGForceUpdate(gForce);

          // Check if G-force exceeds the threshold
          if (gForce > threshold) {
            onThresholdExceeded();
          }

          // Update the last accelerometer update time
          _userAccelerometerUpdateTime = now;
        }
      },
      onError: (e) {
        onError("It seems that your device doesn't support User Accelerometer Sensor");
      },
      cancelOnError: true,
    );
  }

  double calculateGForce(double x, double y, double z) {
    // Calculate the magnitude of acceleration in G-forces
    return sqrt(x * x + y * y + z * z) / 9.8;
  }

  void triggerEmergencyResponse(double gForce) {
    // Add logic to handle the crash detection
    print('Crash detected with g-force: $gForce');
    // Implement emergency response here
  }
}
