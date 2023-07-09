import 'package:shringar1_app/models/active_nearby_available_beauticians.dart';
class GeoFireAssistant
{
  static List<ActiveNearbyAvailableBeauticians> activeNearbyAvailableBeauticiansList = [];

  static void deleteOfflineBeauticianFromList(String beauticianId)
  {
    int indexNumber = activeNearbyAvailableBeauticiansList.indexWhere((element) => element.beauticianId == beauticianId);
    activeNearbyAvailableBeauticiansList.removeAt(indexNumber);
  }

  static void updateActiveNearbyAvailableBeauticianLocation(ActiveNearbyAvailableBeauticians beauticianWhoMove)
  {
    int indexNumber = activeNearbyAvailableBeauticiansList.indexWhere((element) => element.beauticianId == beauticianWhoMove.beauticianId);

    activeNearbyAvailableBeauticiansList[indexNumber].locationLatitude = beauticianWhoMove.locationLatitude;
    activeNearbyAvailableBeauticiansList[indexNumber].locationLongitude = beauticianWhoMove.locationLongitude;

  }
}