import 'package:flutter/material.dart';

import 'provider/userprovider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_detail_screen.dart';
import 'vision_detector_views/face_detector_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        home: InitialScreen(),
      ),
    );
  }
}

class InitialScreen extends StatefulWidget {
  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  bool? _isFormCompleted;

  @override
  void initState() {
    super.initState();
    // var preminssion = Geolocator.requestPermission();
    // checkLocationPermission();
    _checkIfFormCompleted();
  }

  Future<void> _checkIfFormCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFormCompleted = prefs.getBool('isFormCompleted') ?? false;

    setState(() {
      _isFormCompleted = isFormCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen or loading until check is done
    if (_isFormCompleted == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If form is completed, navigate to the main page
    if (_isFormCompleted!) {
      return FaceDetectorView(); // Replace with your main screen widget
    }

    // Otherwise, show the form
    return UserDetailsForm();
  }
}
