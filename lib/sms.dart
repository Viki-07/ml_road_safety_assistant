import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'location_service.dart';
import 'provider/userprovider.dart';

class Sms {
  void sendSms(dynamic context, String mode) async {
    var _currentPosition = await LocationHandler.getCurrentPosition();
            var _currentAddress =
                await LocationHandler.getAddressFromLatLng(_currentPosition!);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var url = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/AC41483aa27034fc7363e0fa569219ddc3/Messages.json');
    var messageBody =
        "Alert! ${userProvider.firstName} ${userProvider.lastName}, aged ${userProvider.age}, may be experiencing drowsiness while driving. Please check on them immediately. Blood Group: ${userProvider.bloodGroup}. Current location: ${_currentAddress} (Lat: ${_currentPosition!.latitude}, Long: ${_currentPosition!.longitude}). Contact them or emergency services if needed.";
    var messageBody1 =
        "Alert! ${userProvider.firstName} ${userProvider.lastName}, aged ${userProvider.age}, may have crashed while driving. Please check on them immediately. Blood Group: ${userProvider.bloodGroup}. Current location: ${_currentAddress} (Lat: ${_currentPosition!.latitude}, Long: ${_currentPosition!.longitude}). Contact them or emergency services if needed.";

    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode(
                'AC41483aa27034fc7363e0fa569219ddc3:979664e3cf538f5d99e6f6300a501a1d')),
      },
      body: {
        'To': '+917017448797',
        'From': '+12088421813',
        'Body': mode=="Drowsy"?messageBody:messageBody1,
      },
    );

    if (response.statusCode == 201) {
      print('Message sent successfully');
    } else {
      print('Failed to send message: ${response.body}');
    }
  }
}
