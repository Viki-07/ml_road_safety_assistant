import 'dart:async';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:awake_safe/speed_limit_sign.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import '../crash_functionality.dart';
import '../provider/userprovider.dart';
import '../quick_alerts.dart';
import '../settings_screen.dart';
import '../sms.dart';
import 'detector_view.dart';
import 'painters/face_detector_painter.dart';

// import 'package:maps/functions.dart';
class FaceDetectorView extends StatefulWidget {
  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  double gForce = 0;
  double maxgForce = -1;
  double threshold = 6.0; // Example threshold for acceleration
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  int drowsinessLevel = 0;
  double averageEyeOpen = 0;
  Duration sensorInterval = SensorInterval.normalInterval;

  static const Duration _ignoreDuration = Duration(milliseconds: 20);

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableClassification: true,
      enableContours: true,
      enableLandmarks: true,
    ),
  );

  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  String userSpeed = '0';
  double speedLimit = 40.0;
  // Lists to store eye open probabilities for moving average
  List<double> leftEyeProbabilities = [];
  List<double> rightEyeProbabilities = [];
  final int frameCount = 5; // Number of frames for averaging

  // Create an AudioPlayer instance
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isDialogVisible = false;

  int _drowsyAlertCount = 0; // Counter for drowsy alerts

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    _audioPlayer.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void showToast(String toastMessage) {
    CherryToast.warning(
      toastDuration: Duration(seconds: 8),
      description: Text(toastMessage, style: TextStyle(color: Colors.black)),
      animationType: AnimationType.fromLeft,
      // action: Text("Backup data", style: TextStyle(color: Colors.black)),
      actionHandler: () {
        print("Hello World!!");
      },
    ).show(context);
  }

  void getSpeed() {
    Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        forceLocationManager: true,
        accuracy: LocationAccuracy.bestForNavigation,
        intervalDuration: Duration(seconds: 3),
        distanceFilter: 2,
      ),
    ).listen((position) {
      // Convert speed from m/s to km/h
      double speedInKmh = position.speed * 3.6;
      // double speedInKmh=200;
      userSpeed = speedInKmh.toInt().toString(); // this is your speed in km/h
      if (speedInKmh.toInt() > speedLimit) {
        showToast("You are going over speed limit ! Please slow down. ");
      }
      print(userSpeed);
    });
  }

  void crashFunctionality() {
    // Check if crash detection is enabled before running the functionality
    if (!Provider.of<UserProvider>(context, listen: false).crashDetection)
      return;
    double threshold= Provider.of<UserProvider>(context, listen: false).crashGvalue!;
    final subscription = CrashFunction(ignoreDuration: _ignoreDuration)
        .listenToAccelerometerEvents(
      userAccelerometerEventStream:
          userAccelerometerEventStream(samplingPeriod: sensorInterval),
      threshold: threshold,
      onGForceUpdate: (double updatedGForce) {
        setState(() {
          gForce = updatedGForce;
        });
      },
      onThresholdExceeded: () {
        if (!_isDialogVisible) {
          setState(() {
            _isDialogVisible = true;
          });
          QuickAlertsDialog(
            context: context,
            onCountdownUpdate: (int time) {
              setState(() {});
            },
            onCountdownComplete: () {
              Sms().sendSms(context,"Crash"); // Trigger SMS or emergency action here
            },
            onDialogClose: () {
              setState(() {
                _isDialogVisible = false;
              });
              Navigator.of(context).pop(); // Close dialog
            },
          ).showGForceAlert(gForce: gForce);
        }
      },
      onError: (String errorMessage) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Sensor Not Found'),
              content: Text(errorMessage),
            );
          },
        );
      },
    );

    // Add subscription to the list
    _streamSubscriptions.add(subscription);
  }

  Future<void> checkLocationPermission() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Permissions are granted, continue with location updates
    getSpeed();
  }

  @override
  initState() {
    super.initState();
    checkLocationPermission();
    if (Provider.of<UserProvider>(context, listen: false).crashDetection) {
      crashFunctionality();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (maxgForce < gForce) {
      setState(() {
        maxgForce = gForce;
      });
    }
    return Consumer<UserProvider>(
      builder: (context, userDataProvider, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Awake & Safe'),
          actions: [
            IconButton(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SettingsScreen())),
                icon: Icon(Icons.settings))
          ],
        ),
        body: SafeArea(
          minimum: EdgeInsets.all(3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Padding(
              //     padding: EdgeInsets.fromLTRB(20, 20, 10, 5),
              //     child: Container(
              //       width: 20,
              //       height: 20,
              //       child: Row(
              //         children: [Image.asset('assets/eye.png')],
              //       ),
              //     )),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: SizedBox(
                    width: 390,
                    height: 400,
                    child: userDataProvider.drowsyDetection
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: DetectorView(
                              customPaint: _customPaint,
                              text: _text,
                              onImage: _processImage,
                              initialCameraLensDirection: _cameraLensDirection,
                              onCameraLensDirectionChanged: (value) =>
                                  _cameraLensDirection = value,
                              title: 'Hi',
                            ),
                          )
                        : Container(
                            decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(width: 2))),
                            child: Icon(
                              Icons.videocam_off_outlined,
                              size: 100,
                            )),
                  ),
                ),
              ),
              Container(
                height: 60,
                width: 400,
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        _text == 'No face detected.'
                            ? 'No face detected'
                            : 'Drowsiness Level ${((1 - averageEyeOpen) * 100).toStringAsFixed(2)}%',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SimpleAnimationProgressBar(
                        height: 20,
                        width: 100,
                        backgroundColor: Colors.grey.shade800,
                        foregrondColor: Colors.purple,
                        ratio: _text == 'No face detected.'
                            ? 0
                            : ((1 - averageEyeOpen) * 100) / 100.toInt(),
                        direction: Axis.horizontal,
                        curve: Curves.linear,
                        duration: const Duration(milliseconds: 200),
                        borderRadius: BorderRadius.circular(10),
                        gradientColor: const LinearGradient(
                            colors: [Colors.green, Colors.red]),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: const Color.fromARGB(255, 54, 51, 52),
                        //     offset: const Offset(
                        //       5.0,
                        //       5.0,
                        //     ),
                        //     blurRadius: 10.0,
                        //     spreadRadius: 2.0,
                        //   ),
                        // ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 400,
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: SwitchListTile(
                        value: userDataProvider.drowsyDetection,
                        onChanged: (bool x) {
                          userDataProvider.toggleDrowsyDetection();
                        },
                        title: Text('Drowsy Detection'),
                      )),
                      Expanded(
                          child: SwitchListTile(
                        value: userDataProvider.crashDetection,
                        onChanged: (bool isEnabled) {
                          userDataProvider.toggleCrashDetection();

                          if (!isEnabled) {
                            // Cancel all active subscriptions when crash detection is turned off
                            for (final subscription in _streamSubscriptions) {
                              subscription.cancel();
                            }
                            _streamSubscriptions
                                .clear(); // Clear the subscription list
                          } else {
                            // Start crash detection again when turned back on
                            crashFunctionality();
                          }
                        },
                        title: Text('Crash Detection'),
                      ))
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 400,
                  height: 160,
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(40, 10, 10, 0),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontFamily: 'digital',
                                      fontSize: userSpeed.length >= 3
                                          ? 70
                                          : 90, // Adjust font size for 3 digits
                                      color: Colors
                                          .black, // Adjust color as needed
                                    ),
                                    children: [
                                      TextSpan(
                                          text: userSpeed), // Display speed
                                      WidgetSpan(
                                        child: Transform.translate(
                                          offset: const Offset(
                                              0, 20), // Move the text down
                                          child: Text(
                                            ' km/hr',
                                            style: TextStyle(
                                              fontSize:
                                                  25, // Smaller font for subscript effect
                                              fontFamily: 'digital',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      40), // Adjust spacing to fit the design
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 35, 0, 0),
                                child: SizedBox(
                                  width: 85,
                                  child: SpeedLimitSign(
                                      speedLimit:
                                          speedLimit.toInt().toString()),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SfSlider(
                            min: 0.0,
                            max: 140.0,
                            value: speedLimit,
                            interval: 20,
                            showTicks: true,
                            showLabels: true,
                            enableTooltip: true,
                            stepSize: 10,
                            minorTicksPerInterval: 1,
                            onChanged: (dynamic value) {
                              setState(() {
                                speedLimit = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )

              // Expanded(
              //   flex: 1, // 25% of the screen
              //   child: Container(
              //     padding: EdgeInsets.all(16.0),
              //     color: Colors.white,
              //     child: SingleChildScrollView(
              //       child: Column(
              //         children: [
              //           Text(
              //             _text ?? 'No results yet',
              //             style:
              //                 TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              //           ),
              //           Text(
              //               'X: ${_userAccelerometerEvent?.x.toStringAsFixed(2) ?? 'N/A'}'),
              //           Text(
              //               'Y: ${_userAccelerometerEvent?.y.toStringAsFixed(2) ?? 'N/A'}'),
              //           Text(
              //               'Z: ${_userAccelerometerEvent?.z.toStringAsFixed(2) ?? 'N/A'}'),
              //               SizedBox(height: 30,),
              // Text(gForce.toString()),
              // Text(maxgForce.toString()),

              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      _text = 'No face detected.';
    } else {
      final face = faces.first;

      // Check the eye open probabilities
      final leftEyeOpen = face.leftEyeOpenProbability;
      final rightEyeOpen = face.rightEyeOpenProbability;

      if (leftEyeOpen != null && rightEyeOpen != null) {
        // Add the current probabilities to the lists
        leftEyeProbabilities.add(leftEyeOpen);
        rightEyeProbabilities.add(rightEyeOpen);

        // Keep the lists' sizes under the defined frame count
        if (leftEyeProbabilities.length > frameCount) {
          leftEyeProbabilities.removeAt(0);
          rightEyeProbabilities.removeAt(0);
        }

        // Calculate average probabilities
        final avgLeftEyeOpen = leftEyeProbabilities.reduce((a, b) => a + b) /
            leftEyeProbabilities.length;
        final avgRightEyeOpen = rightEyeProbabilities.reduce((a, b) => a + b) /
            rightEyeProbabilities.length;
        averageEyeOpen = (avgLeftEyeOpen + avgRightEyeOpen) / 2;

        // Drowsiness detection logic
        if (averageEyeOpen < 0.3 && !_isDialogVisible) {
          // Adjust threshold as needed
          _text = 'Drowsiness detected.\n';

          // Trigger haptic feedback
          if (userProvider.toggleHapticValue) {
            HapticFeedback.vibrate();
          }

          // Play alert sound
          if (userProvider.toggleAudioValue) {
            await _audioPlayer.setReleaseMode(ReleaseMode.loop);
            await _audioPlayer.play(AssetSource('alarm3.mp3'));
          }

          // Increment the drowsy alert counter
          _drowsyAlertCount++;
          _showDrowsinessDialog();
          // Send SMS if drowsy alert count reaches 2
          if (_drowsyAlertCount >= 2) {
            Sms().sendSms(context,"Drowsy");
            _drowsyAlertCount = 0; // Reset the counter after sending SMS
          }

          // Show the dialog to ask the driver to take a rest
        } else {
          _text = 'No drowsiness.\n';
        }

        // Add eye open probabilities to the message
        _text =
            '${_text!}Left Eye Open Probability: ${leftEyeOpen.toStringAsFixed(2)}\nRight Eye Open Probability: ${rightEyeOpen.toStringAsFixed(2)}';
      } else {
        _text = 'Could not determine eye positions.';
      }

      // Prepare the custom painter
      _customPaint = CustomPaint(
        painter: FaceDetectorPainter(
          faces,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        ),
      );
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  // Function to show the dialog when drowsiness is detected
  void _showDrowsinessDialog() {
    if (_isDialogVisible) return; // Prevent showing multiple dialogs
    _isDialogVisible = true; // Set to true to indicate the dialog is visible

    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      text: 'Drowsiness detected! Please take a break',
      onConfirmBtnTap: () async {
        await _audioPlayer.stop(); // Stop the audio when OK is pressed
        _isDialogVisible = false; // Reset the flag
        Navigator.of(context).pop(); // Dismiss the alert
      },
    );
  }
}
