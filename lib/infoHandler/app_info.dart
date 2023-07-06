import 'package:flutter/cupertino.dart';
import 'package:shringar1_app/models/directions.dart';

class AppInfo extends ChangeNotifier
{
  Directions? userHomeLocation;

  void updateHomeLocationAddress(Directions userHomeAddress)
  {
    userHomeLocation = userHomeAddress;
    notifyListeners();
  }
}

