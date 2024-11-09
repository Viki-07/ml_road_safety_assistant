import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/userprovider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? firstName, lastName, bloodGroup, emergencyContact1, emergencyContact2;
  int? age;
  TextEditingController CrashThresholdValue = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Load user data when the screen initializes
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await Provider.of<UserProvider>(context, listen: false).loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userDataProvider, child) => Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // First Name
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  initialValue: userDataProvider.firstName ?? '', // Pre-filled
                  onSaved: (value) => firstName = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Last Name
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  initialValue: userDataProvider.lastName ?? '', // Pre-filled
                  onSaved: (value) => lastName = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Age
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cake),
                  ),
                  initialValue:
                      userDataProvider.age?.toString() ?? '', // Pre-filled
                  keyboardType: TextInputType.number,
                  onSaved: (value) => age = int.tryParse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Blood Group
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Blood Group',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                  initialValue: userDataProvider.bloodGroup ?? '', // Pre-filled
                  onSaved: (value) => bloodGroup = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your blood group';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Emergency Contact 1
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Emergency Contact No. 1',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  initialValue:
                      userDataProvider.emergencyContact1 ?? '', // Pre-filled
                  keyboardType: TextInputType.phone,
                  onSaved: (value) => emergencyContact1 = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the first emergency contact number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Emergency Contact 2
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Emergency Contact No. 2',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  initialValue:
                      userDataProvider.emergencyContact2 ?? '', // Pre-filled
                  keyboardType: TextInputType.phone,
                  onSaved: (value) => emergencyContact2 = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the second emergency contact number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                // Switch for Audio Alert
                SwitchListTile(
                  title: Text('Enable Audio Alert'),
                  value: userDataProvider.toggleAudioValue,
                  onChanged: (bool newValue) {
                    userDataProvider.toggleAudio();
                  },
                ),

                // Switch for Haptic Feedback Alert
                SwitchListTile(
                  title: Text('Enable Haptic Feedback Alert'),
                  value: userDataProvider.toggleHapticValue,
                  onChanged: (bool newValue) {
                    userDataProvider.toggleHaptic();
                  },
                ),
                TextFormField(
                  onSaved: (newValue) {
                    userDataProvider.setGvalue(newValue as double);
                  },
                  // controller: CrashThresholdValue,
                  decoration: InputDecoration(
                    labelText: 'Crash Threshold Gs',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.car_crash),
                  ),
                  initialValue: userDataProvider.crashGvalue.toString() ??
                      '', // Pre-filled
                  keyboardType: TextInputType.phone,
                ),
                // SizedBox(
                //   width: 400,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Expanded(
                //           child: SwitchListTile(
                //         value: userDataProvider.drowsyDetection,
                //         onChanged: (bool x) {
                //           userDataProvider.toggleDrowsyDetection();
                //         },
                //         title: Text('Drowsy Detection'),
                //       )),
                //       Expanded(
                //           child: SwitchListTile(
                //         value: userDataProvider.crashDetection,
                //         onChanged: (bool x) {
                //           userDataProvider.();
                //         },
                //         title: Text('Crash Detection'),
                //       ))
                //     ],
                //   ),
                // ),

                // Save Button
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      // Update the provider with new data
                      userDataProvider.setFirstName(firstName!);
                      userDataProvider.setLastName(lastName!);
                      userDataProvider.setAge(age!);
                      userDataProvider.setBloodGroup(bloodGroup!);
                      userDataProvider.setEmergencyContact1(emergencyContact1!);
                      userDataProvider.setEmergencyContact2(emergencyContact2!);

                      // Save the updated data to SharedPreferences
                      await userDataProvider.saveUserData();

                      // Show confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Information Updated Successfully')),
                      );
                    }
                  },
                  child: Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
