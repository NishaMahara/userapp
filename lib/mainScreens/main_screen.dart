import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shringar1_app/assistants/assistant_methods.dart';
import 'package:shringar1_app/assistants/geofire_assistant.dart';
import 'package:shringar1_app/global/global.dart';
import 'package:shringar1_app/global/map_key.dart';
import 'package:shringar1_app/main.dart';
import 'package:shringar1_app/models/user_model.dart';
import 'package:shringar1_app/models/directions.dart';
import 'package:shringar1_app/infoHandler/app_info.dart';
import 'package:shringar1_app/models/active_nearby_available_beauticians.dart';
import 'package:shringar1_app/widgets/my_drawer.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:shringar1_app/mainScreens/search_services_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController serviceTextEditingController = TextEditingController();

  List<String> serviceTypeList = ["haircut", "eyebrow", "nailart"];
  String? selectedServiceType;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 220;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;
  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String userName = "your Name";
  String userEmail = "your Email";

  bool openNavigationDrawer = true;

  bool activeNearbyBeauticianKeysLoaded = false;
  //BitmapDescriptor? activeNearbyIcon;
  List<ActiveNearbyAvailableBeauticians> onlineNearByAvailableBeauticiansList = [];
  Future<void> checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  Future<void> locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    userCurrentPosition = cPosition;

    LatLng latLngPosition =
    LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(
      target: latLngPosition,
      zoom: 14,
    );

    newGoogleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(
      userCurrentPosition!,
      context,
    );
    print("this is your address = " + humanReadableAddress);
    initializeGeoFireListener();
  }

  void saveSelectedService(String service) {
    setState(() {
      selectedServiceType = service;
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
  }
saveServiceRequestInformation()
{
  //save the service request information
 onlineNearByAvailableBeauticiansList = GeoFireAssistant.activeNearbyAvailableBeauticiansList;
 searchNearestOnlineBeauticians();
}
  searchNearestOnlineBeauticians() async
  {
    if(onlineNearByAvailableBeauticiansList.length == 0)
      {
        //cancel the Request Information
        setState(() {
          polyLineSet.clear();
          markersSet.clear();
          circlesSet.clear();
          pLineCoOrdinatesList.clear();
        });
        Fluttertoast.showToast(msg: "No online Nearest Beautician available");
        MyApp.restartApp(context);
        return;
      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade300,
      ),
      drawer: Container(
        width: 260,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.white,
          ),
          child: MyDrawer(
            name: userModelCurrentInfo!.name,
            email: userModelCurrentInfo!.email,
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 240;
              });

              locateUserPosition();
            },
          ),

          // UI for searching location
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: searchLocationContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  child: Column(
                    children: [
                      // From
                      Row(
                        children: [
                          const Icon(
                            Icons.add_location_alt_outlined,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Location",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                Provider.of<AppInfo>(context).userHomeLocation != null
                                    ? Provider.of<AppInfo>(context).userHomeLocation!.locationName!.substring(0, 24) + "..."
                                    : "not getting address",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10.0),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16.0),

                      GestureDetector(
                        onTap: () async {
                          var selectedService = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchServicesScreen(),
                            ),
                          );
                          if (selectedService != null) {
                            setState(() {
                              selectedServiceType = selectedService;
                            });

                            // Save the selected service
                            saveSelectedService(selectedService);
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add_box_sharp,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 12.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Service",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  selectedServiceType != null
                                      ? selectedServiceType!
                                      : "Select a service",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10.0),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16.0),

                      ElevatedButton(
                        child: const Text("Request For Service"),
                        onPressed: () {
                          if (Provider.of<AppInfo>(context, listen: false).userHomeLocation != null &&
                              selectedServiceType != null) {
                            saveServiceRequestInformation();
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please select service");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade300,
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void initializeGeoFireListener()
  {
    Geofire.initialize("activeBeauticians");
    Geofire.queryAtLocation(
      userCurrentPosition!.latitude,
      userCurrentPosition!.longitude,
      10,
    )?.listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
        // Whenever any Beautician is online
          case Geofire.onKeyEntered:
            ActiveNearbyAvailableBeauticians activeNearbyAvailableBeauticians =
            ActiveNearbyAvailableBeauticians();
            activeNearbyAvailableBeauticians.locationLatitude =
            map['latitude'];
            activeNearbyAvailableBeauticians.locationLongitude =
            map['longitude'];
            activeNearbyAvailableBeauticians.beauticianId = map['key'];
            GeoFireAssistant.activeNearbyAvailableBeauticiansList
                .add(activeNearbyAvailableBeauticians);
            if (activeNearbyBeauticianKeysLoaded == true) {
              displayActiveBeauticiansOnUsersMap();
            }
            break;

        // When any beautician becomes offline
          case Geofire.onKeyExited:
            GeoFireAssistant.deleteOfflineBeauticianFromList(map['key']);
            break;

        // When Beautician moves
          case Geofire.onKeyMoved:
            ActiveNearbyAvailableBeauticians activeNearbyAvailableBeautician =
            ActiveNearbyAvailableBeauticians();
            activeNearbyAvailableBeautician.locationLatitude =
            map['latitude'];
            activeNearbyAvailableBeautician.locationLongitude =
            map['longitude'];
            activeNearbyAvailableBeautician.beauticianId = map['key'];
            GeoFireAssistant.updateActiveNearbyAvailableBeauticianLocation(
                activeNearbyAvailableBeautician);
            displayActiveBeauticiansOnUsersMap();
            break;

        // Display online Beauticians on the user's map
          case Geofire.onGeoQueryReady:
            displayActiveBeauticiansOnUsersMap();
            break;
        }
      }

      setState(() {});
    });
  }

  void displayActiveBeauticiansOnUsersMap() {
    setState(() {
      markersSet.clear();
      circlesSet.clear();

      Set<Marker> beauticiansMarkerSet = Set<Marker>();
      for (ActiveNearbyAvailableBeauticians eachBeautician
      in GeoFireAssistant.activeNearbyAvailableBeauticiansList) {
        LatLng eachBeauticianActivePosition =
        LatLng(eachBeautician.locationLatitude!, eachBeautician.locationLongitude!);
        Marker marker = Marker(
          markerId: MarkerId("Beautician${eachBeautician.beauticianId.toString()}"),
          position: eachBeauticianActivePosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          rotation: 360,
        );

        beauticiansMarkerSet.add(marker);
      }
      setState(() {
        markersSet = beauticiansMarkerSet;
      });
    });
  }
}

