import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:shringar1_app/global/global.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shringar1_app/assistants/request_assistant.dart';
import 'package:shringar1_app/global/global.dart';
import 'package:shringar1_app/global/map_key.dart';
import 'package:shringar1_app/infoHandler/app_info.dart';
import 'package:shringar1_app/models/user_model.dart';
import 'package:http/http.dart' as http;

import '../models/directions.dart';


class AssistantMethods {
  static Future<String> searchAddressForGeographicCoOrdinates(Position position,
      context) async
  {
    // String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position
        .latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error Occurred, Failed. No Response.")
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

    {
      Directions userHomeAddress = Directions();
      userHomeAddress.locationLatitude = position.latitude;
      userHomeAddress.locationLongitude = position.longitude;
      userHomeAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false).updateHomeLocationAddress(
          userHomeAddress);
    }

    return humanReadableAddress;
  }

  static readCurrentOnlineUserInfo() async
  {
    {
      currentFirebaseUser = fAuth.currentUser;
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(currentFirebaseUser!.uid);
      userRef.once().then((snap) {
        if (snap.snapshot.value != null) {
          userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
        }
      });
    }
  }

  static sendNotificationToBeautician(String deviceregistrationToken,
      String userserviceRequestId, context) async
  {
    var destinationAddress = Provider
        .of<AppInfo>(context, listen: false)
        .userHomeLocation;
    Map<String, String> headerNotification =
    {
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingServerToken,
    };

    Map bodyNotification =
    {
      "body": "Destination Address, $destinationAddress.",
      "title": "New Service Request"
    };

    Map dataMap =
    {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "serviceRequestId": "userserviceRequestId"
    };

    Map officialNotificationFormat =
    {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": deviceregistrationToken,
    };
    var responseNotification = http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: headerNotification,
        body: jsonEncode(officialNotificationFormat),
    );
  }
}
