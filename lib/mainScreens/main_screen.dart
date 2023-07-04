import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shringar1_app/assistants/assistant_methods.dart';
import 'package:shringar1_app/widgets/my_drawer.dart';

import '../authentication/login_screen.dart';
import '../global/global.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
{
  TextEditingController serviceTextEditingController = TextEditingController();

  List<String> serviceTypeList = ["haircut", "eyebrow", "nailart"];
  String? selectedServiceType;

   final Completer<GoogleMapController> _controllerGoogleMap = Completer();
   GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex =  CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> sKey=GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight=220;

   Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  checkIfLocationPermissionAllowed() async
  {
    _locationPermission = await Geolocator.requestPermission();

    if(_locationPermission == LocationPermission.denied)
      {
        _locationPermission = await Geolocator.requestPermission();
      }


  }


locateUserPosition() async
{
   Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
   userCurrentPosition = cPosition;

   LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

   CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14 );

   newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

}
@override
  void initState() {

    super.initState();
    checkIfLocationPermissionAllowed();

  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
      ),
      drawer: Container(
        width: 260,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.black,
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
            //padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller)
    {
      _controllerGoogleMap.complete(controller);
      newGoogleMapController = controller;

      setState(() {
        bottomPaddingOfMap = 240;
      });

      locateUserPosition();


      },

          ),

          //ui for searching location
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: searchLocationContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  )
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 18),
                  child: Column(
                    children: [
                      //from
                      Row(
                         children: [
                           const Icon (Icons.add_location_alt_outlined, color: Colors.white,),
                           const SizedBox(width: 12.0,),
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                              const Text(
                                 "Location",
                                 style: TextStyle(color: Colors.white, fontSize: 16),
                               ),
                               Text(
                                 "Your Location",
                                 style: const TextStyle(color: Colors.grey, fontSize: 14),
                               ),
                             ],
                           )


                         ],
                      ),

                      const SizedBox(height: 10.0),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16.0),

                   //new services


                      // TextField(
                      //   controller: serviceTextEditingController,
                      //   style: TextStyle(
                      //       color: Colors.white70
                      //   ),
                      //   decoration:  const InputDecoration(
                      //       labelText: "Services",
                      //       hintText: "Beauty service you need",
                      //
                      //       enabledBorder: UnderlineInputBorder(
                      //         borderSide: BorderSide(color:Colors.grey),
                      //       ),
                      //
                      //       focusedBorder: UnderlineInputBorder(
                      //         borderSide: BorderSide(color:Colors.grey),
                      //       ),
                      //       hintStyle: TextStyle(
                      //         color: Colors.white70,
                      //         fontSize: 10,
                      //       ),
                      //       labelStyle: TextStyle(
                      //         color: Colors.white,
                      //         fontSize: 20,
                      //       )
                      //   ),
                      //
                      // ),
                      const SizedBox(height: 10.0),
                      DropdownButton(
                        iconSize: 45,
                        dropdownColor: Colors.grey,
                        hint: const Text(
                          "please choose service type",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey,
                          ),
                        ),
                        value: selectedServiceType,
                        onChanged: (newValue) {
                          setState(() {
                            selectedServiceType = newValue.toString();
                          });
                        },
                        items: serviceTypeList.map((service) {
                          return DropdownMenuItem(
                            child: Text(
                              service,
                              style: const TextStyle(color: Colors.white),
                            ),
                            value: service,
                          );
                        }).toList(),
                      ),



                      // DropdownButton(
              //   hint: const Text(
              //     "please choose service type",
              //     style:TextStyle(
              //       fontSize: 14.0,
              //       color: Colors.grey,
              //
              //     )
              //   )
              //       value: selectedServiceType,
              //   onChanged: (newValue)
              //   {
              //     setState(() {
              //       selectedServiceType = newValue.toString();
              //
              //
              //     });
              //   },
              //   items: serviceTypeList.map((service){
              //     return DropdownMenuItem(
              //     child: Text(
              //      service,
              //     style: const TextStyle(color: Colors.grey),
              //     ),
              //     value: service,
              //     );
              // }).toList(),
              //    ),
              //









                      ElevatedButton(
                        child: const Text(
                        "Request For Service",
                      ),
                      onPressed: ()
                    {

                    },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                       textStyle: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold )
                        )
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );

  }
}
