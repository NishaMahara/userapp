import 'dart:async';
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shringar1_app/assistants/assistant_methods.dart';
import 'package:shringar1_app/assistants/geofire_assistant.dart';
import 'package:shringar1_app/global/global.dart';
import 'package:shringar1_app/global/map_key.dart';
import 'package:shringar1_app/main.dart';
import 'package:shringar1_app/mainScreens/select_nearest_active_beautician_screen.dart';
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
  double waitingResponseFromBeaiuticianContainerHeight = 0;
  double assignedBeauticianInfoContainerHeight = 0;


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
  List<ActiveNearbyAvailableBeauticians> onlineNearByAvailableBeauticiansList = [];
  DatabaseReference?  referenceServiceRequest;

  //status
  String beauticianserviceStatus="Beautician is comming";

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

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(userCurrentPosition!, context,);
    print("this is your address = " + humanReadableAddress);
    initializeGeoFireListener();
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
  }

  void saveServiceRequestInformation() {
    // Save the service request information
    referenceServiceRequest = FirebaseDatabase.instance.ref().child("All Service Requests").push();//hjasdg8
    var usersLocation = Provider.of<AppInfo>(context, listen: false).userHomeLocation;
   // var requestedService= Provider.of<AppInfo>(context, listen: false). serviceRequested;

    Map usersLocationMap=
    {
      "latitude": usersLocation!.locationLatitude.toString(),
      "longitude": usersLocation!.locationLongitude.toString(),
    };

    // Map requestedServiceMap=
    // {
    //   "latitude": usersLocation!.locationLatitude.toString(),
    //   "longitude": usersLocation!.locationLongitude.toString(),
    // };
     Map userInformationMap =
     {
       "Address": usersLocationMap,
       //"service": requestedServiceMap,
       "time": DateTime.now().toString(),
       "userName": userModelCurrentInfo!.name,
       "userPhone": userModelCurrentInfo!.phone,
       "userAddress": usersLocation.locationName,
       "beauticianId": "waiting",
       "selected_service": selectedServiceType,
       //"requestedService": requestedService
     };

     referenceServiceRequest!.set(userInformationMap);



    onlineNearByAvailableBeauticiansList =
        GeoFireAssistant.activeNearbyAvailableBeauticiansList;
    searchNearestOnlineBeauticians();
  }

  searchNearestOnlineBeauticians() async {
    // No online beautician available
    if (onlineNearByAvailableBeauticiansList.isEmpty) {
      // Cancel the request information
      referenceServiceRequest!.remove();

      setState(() {
        polyLineSet.clear();
        markersSet.clear();
        circlesSet.clear();
        pLineCoOrdinatesList.clear();
      });
      Fluttertoast.showToast(msg: "No beauticians available. Please try again later.");

      Future.delayed(const Duration(milliseconds: 7000),()
      {
        SystemNavigator.pop();
      });
    }

    // Beauticians available
    await retrieveOnlineBeauticiansInformation(onlineNearByAvailableBeauticiansList);
     var response = await Navigator.push(context, MaterialPageRoute(builder: (c) => SelectNearestActiveBeauticiansScreen(referenceServiceRequest: referenceServiceRequest )));
     if(response == "beauticianChoosed")
     {
FirebaseDatabase.instance.ref()
    .child("beauticians")
    .child(chosenBeauticianId!)
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
        {
      //sent notification to that Beautician
          sendNotificationToBeauticianNow(chosenBeauticianId!);

          //waiting response from beautician ui
          showWaitingResponseFRomBeauticianUI();

          //response from beautician


          FirebaseDatabase.instance.ref()
              .child("beauticians")
              .child(chosenBeauticianId!)
               .child("newServiceStatus")

              .onValue.listen((eventSnapshot)
              {
                //how

                //beautician has cancel the service request :: push notification
                //(newserviceStatus = idle)
                if(eventSnapshot.snapshot.value == "idle")
                  {
                      Fluttertoast.showToast(msg: "beautician has cancelled yr request");
                      Future.delayed(const Duration(milliseconds: 3000), ()
                          {
                            Fluttertoast.showToast(msg: "restart app now.");
                            SystemNavigator.pop();
                          });

                  }



                // beautician has accept the service request :: push notification
                //(newserviceStatus = accepted)
                if(eventSnapshot.snapshot.value == "accepted")
                {
                    //design and display ui for displaying assigned beautician information
                  showUIForAssignedBeauticianInfo();
                }


              });

        }
      else
        {
          Fluttertoast.showToast(msg:"This Beautician not exist.");
        }
    });
     }

  }
showUIForAssignedBeauticianInfo() {
  setState(() {
    searchLocationContainerHeight = 0;
    waitingResponseFromBeaiuticianContainerHeight = 0;
    assignedBeauticianInfoContainerHeight = 220;
  });
}


  showWaitingResponseFRomBeauticianUI()
  {
    setState(() {

      searchLocationContainerHeight = 0;
      waitingResponseFromBeaiuticianContainerHeight = 200;

    });
  }

  sendNotificationToBeauticianNow(String chosenBeauticianId) {
    //assign service request id to new service request status in beauticians parentrs node for that specific choosen beautician

    FirebaseDatabase.instance.ref()
        .child("beauticians")
        .child(chosenBeauticianId!)
        .child("newServiceStatus")
        .set(referenceServiceRequest!.key);
    //automate push notification

    FirebaseDatabase.instance.ref()
        .child("beauticians")
        .child(chosenBeauticianId!)
        .child("chosenBeauticianId")
        .child("token").once().then((snap)
    {

      if(snap.snapshot.value != null) {
        //String tokendeviceRegistrationToken = snap.snapshot.value.toString();

        String deviceRegistrationToken = snap.snapshot.value.toString();

        //send notification now

        AssistantMethods.sendNotificationToBeautician(
            deviceRegistrationToken,
            referenceServiceRequest!.key.toString(),
            context,
        );

Fluttertoast.showToast(msg: "Notification sent successsfully");

      }
      else{
        Fluttertoast.showToast(msg: "please choose the another Beautician.");
        return;
      }
    });
  }
  retrieveOnlineBeauticiansInformation(List onlineNearestBeauticiansList) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("beauticians");
    for (int i = 0; i < onlineNearestBeauticiansList.length; i++) {
      await ref
          .child(onlineNearestBeauticiansList[i].beauticianId.toString())
          .once()
          .then((dataSnapshot)
      {
        var beauticianKeyInfo = dataSnapshot.snapshot.value;
        bList.add(beauticianKeyInfo);
        print("BeauticianKey Information=" + bList.toString());
      });
    }
  }

  void saveSelectedService(String service) {
    setState(() {
      selectedServiceType = service;
    });
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
            markers: markersSet,
            circles: circlesSet,
            polylines: polyLineSet,
           
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
                              selectedServiceType != null)
                          {

                            saveServiceRequestInformation();

                          }

                          else {
                            Fluttertoast.showToast(msg: "Please select a service");
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

          //ui for waitnig response from beautician
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child:Container(
              height:waitingResponseFromBeaiuticianContainerHeight,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
              child:Center(
                child: AnimatedTextKit(
                  animatedTexts: [
                    FadeAnimatedText(
                      'waiting from response \nfrom beautician',
                      duration: const Duration(seconds: 6),
                      textStyle: const TextStyle(fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    ScaleAnimatedText(
                      'please wait....',
                      duration: const Duration(seconds: 10),
                      textStyle: const TextStyle(fontSize: 32.0, color:Colors.white, fontFamily: 'Canterbury'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //ui for the displaying beautician information

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child:Container(
              height: assignedBeauticianInfoContainerHeight,
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
                  vertical: 20,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      //status of
                      Text(
                        beauticianserviceStatus,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color:Colors.white,
                        ),
                      ),
                          const SizedBox(height: 24.0,
                          ),
                     const Divider(
                        height: 2,
                        thickness: 2,
                        color:Colors.white,
                      ),

                      const SizedBox(height: 24,
                      ),

                     // beautician experience details

                      Text(
                         "5 years experience",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color:Colors.white,
                          ),
                      ),

                      //beautician name
                      const SizedBox(height: 4,
                      ),

                      const Divider(
                        height: 2,
                        thickness: 2,
                        color:Colors.white,
                      ),



                      Text(
                          "priya pant",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color:Colors.white,
                          ),
                      ),


                      const SizedBox(height: 24,
                      ),

                      //call beautician button

                      Center(
                        child: ElevatedButton.icon(
                            onPressed: ()
                         {

                         },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                          ),
                         icon:const Icon(
                            Icons.phone_android,
                          color:Colors.black87,
                          size: 22,
                         ),
                          label: const Text(
                            "call beautician",
                            style:TextStyle(
                              color:Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),



                  ],
                ),
              ),
            ),
          ),


          ]
      ),
    );
  }

  void initializeGeoFireListener() {
    Geofire.initialize("activeBeauticians");
    Geofire.queryAtLocation(
      userCurrentPosition!.latitude,
      userCurrentPosition!.longitude,
      10,
    )!.listen((map) {
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
            if (activeNearbyBeauticianKeysLoaded) {
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
        LatLng(eachBeautician.locationLatitude!,
            eachBeautician.locationLongitude!);
        Marker marker = Marker(
          markerId: MarkerId(eachBeautician.beauticianId!),
          position: eachBeauticianActivePosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange),
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
