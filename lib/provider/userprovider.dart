import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String? firstName;
  String? lastName;
  int? age;
  String? bloodGroup;
  String? emergencyContact1;
  String? emergencyContact2;
  double crashGvalue = 6.0;
  bool toggleAudioValue = true;
  bool toggleHapticValue = true;
  bool drowsyDetection = false;
  bool crashDetection = false;
  void toggleCrashDetection() {
    crashDetection = !crashDetection;
    notifyListeners();
  }

  void toggleDrowsyDetection() {
    drowsyDetection = !drowsyDetection;
    notifyListeners();
  }

  void toggleAudio() {
    toggleAudioValue = !toggleAudioValue;
    notifyListeners();
  }

  void toggleHaptic() {
    toggleHapticValue = !toggleHapticValue;
    notifyListeners();
  }

  void setGvalue(double gvalue) {
    crashGvalue = gvalue;
    notifyListeners();
  }

  // Setters to update user details and notify listeners
  void setFirstName(String value) {
    firstName = value;
    notifyListeners();
  }

  void setLastName(String value) {
    lastName = value;
    notifyListeners();
  }

  void setAge(int value) {
    age = value;
    notifyListeners();
  }

  void setBloodGroup(String value) {
    bloodGroup = value;
    notifyListeners();
  }

  void setEmergencyContact1(String value) {
    emergencyContact1 = value;
    notifyListeners();
  }

  void setEmergencyContact2(String value) {
    emergencyContact2 = value;
    notifyListeners();
  }

  // Save user data to SharedPreferences
  Future<void> saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstName ?? "");
    await prefs.setString('lastName', lastName ?? "");
    await prefs.setInt('age', age ?? 0);
    await prefs.setString('bloodGroup', bloodGroup ?? "");
    await prefs.setString('emergencyContact1', emergencyContact1 ?? "");
    await prefs.setString('emergencyContact2', emergencyContact2 ?? "");
    notifyListeners();
  }

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    firstName = prefs.getString('firstName') ?? "";
    lastName = prefs.getString('lastName') ?? "";
    age = prefs.getInt('age') ?? 0;
    bloodGroup = prefs.getString('bloodGroup') ?? "";
    emergencyContact1 = prefs.getString('emergencyContact1') ?? "";
    emergencyContact2 = prefs.getString('emergencyContact2') ?? "";
    notifyListeners();
  }

  // Clear all user data and SharedPreferences
  Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all stored data
    firstName = null;
    lastName = null;
    age = null;
    bloodGroup = null;
    emergencyContact1 = null;
    emergencyContact2 = null;
    toggleAudioValue = true;
    toggleHapticValue = true;
    notifyListeners();
  }
}
