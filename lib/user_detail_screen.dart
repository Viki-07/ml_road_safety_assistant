import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'provider/userprovider.dart';
import 'vision_detector_views/face_detector_view.dart';

class UserDetailsForm extends StatefulWidget {
  @override
  _UserDetailsFormState createState() => _UserDetailsFormState();
}

class _UserDetailsFormState extends State<UserDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  String? firstName, lastName, bloodGroup;
  int? age;
  String? emergencyContact1, emergencyContact2;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add necessary details'),
        backgroundColor: Colors.teal.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // First Name
              SizedBox(height: 10),
              _buildTextField(
                label: 'First Name',
                icon: Icons.person,
                onSaved: (value) => firstName = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your first name' : null,
              ),
              SizedBox(height: 16),

              // Last Name
              _buildTextField(
                label: 'Last Name',
                icon: Icons.person_outline,
                onSaved: (value) => lastName = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your last name' : null,
              ),
              SizedBox(height: 16),

              // Age
              _buildTextField(
                label: 'Age',
                icon: Icons.cake,
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
              _buildTextField(
                label: 'Blood Group',
                icon: Icons.local_hospital,
                onSaved: (value) => bloodGroup = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your blood group' : null,
              ),
              SizedBox(height: 16),

              // Emergency Contact 1
              _buildTextField(
                label: 'Emergency Contact No. 1',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                onSaved: (value) => emergencyContact1 = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter the first emergency contact number' : null,
              ),
              SizedBox(height: 16),

              // Emergency Contact 2
              _buildTextField(
                label: 'Emergency Contact No. 2',
                icon: Icons.phone_android,
                keyboardType: TextInputType.phone,
                onSaved: (value) => emergencyContact2 = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter the second emergency contact number' : null,
              ),
              SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Update the provider with user data
                    userProvider.setFirstName(firstName!);
                    userProvider.setLastName(lastName!);
                    userProvider.setAge(age!);
                    userProvider.setBloodGroup(bloodGroup!);
                    userProvider.setEmergencyContact1(emergencyContact1!);
                    userProvider.setEmergencyContact2(emergencyContact2!);

                    // Save the form status in SharedPreferences
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setBool('isFormCompleted', true);

                    // Show confirmation and navigate to next page
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Form Submitted Successfully')),
                    );

                    // Navigate to Face Detection view
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => FaceDetectorView()),
                    );
                  }
                },
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, color: Colors.teal.shade600),
        filled: true,
        fillColor: Colors.teal.shade50,
      ),
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: validator,
    );
  }
}
