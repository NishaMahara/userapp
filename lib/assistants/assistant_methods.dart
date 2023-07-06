import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shringar1_app/assistants/request_assistant.dart';
import 'package:shringar1_app/global/global.dart';
import 'package:shringar1_app/global/map_key.dart';
import 'package:shringar1_app/models/user_model.dart';

class AssistantMethods
{
  static Future<String> searchAddressForGeographicCoordinates(Position position) async
  {
  await RequestAssistant.receiveRequest(apiUrl);
  {
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
  }
  static void readCurrentOnlineUserInfo() async
  {
    currentFirebaseUser = fAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid);
    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo=UserModel.fromSnapshot(snap.snapshot);

      }
    });
  }
}