import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/userprovider.dart';

class EditUserprofileScreen extends StatefulWidget {
  const EditUserprofileScreen({Key? key}) : super(key: key);

  @override
  State<EditUserprofileScreen> createState() => _EditUserprofileScreenState();
}

class _EditUserprofileScreenState extends State<EditUserprofileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? firstName, lastName, bloodGroup, emergencyContact1, emergencyContact2;
  int? age;

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
      builder: (context, userDataProvider, child) {
        // Ensure user data is loaded before showing the form
        if (userDataProvider.firstName == null) {
          return Center(child: CircularProgressIndicator()); // Show a loading indicator while loading data
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Settings'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
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
                    initialValue: userDataProvider.age?.toString() ?? '', // Pre-filled
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
                    initialValue: userDataProvider.emergencyContact1 ?? '', // Pre-filled
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
                    initialValue: userDataProvider.emergencyContact2 ?? '', // Pre-filled
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
                          SnackBar(content: Text('Information Updated Successfully')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
