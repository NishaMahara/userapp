import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../global/global.dart';
class SelectNearestActiveBeauticiansScreen extends StatefulWidget {
  DatabaseReference? referenceServiceRequest;
  SelectNearestActiveBeauticiansScreen({this.referenceServiceRequest});

  @override
  State<SelectNearestActiveBeauticiansScreen> createState() => _SelectNearestActiveBeauticiansScreenState();
}

class _SelectNearestActiveBeauticiansScreenState extends State<SelectNearestActiveBeauticiansScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Nearest Online Beauticians",
            style: TextStyle(
              fontSize: 18,
              color: Colors.black
            ),
          ),
          leading: IconButton(
              icon: const Icon(
                  Icons.close, color: Colors.black
              ),
              onPressed: () {
                //cancle the ride request from database
                widget.referenceServiceRequest!.remove();
                Fluttertoast.showToast(msg:"Request Cancelled");
                 SystemNavigator.pop();
              }
          )

      ),
      body: ListView.builder(
        itemCount: bList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap:()
          {
            setState(() {
              chosenBeauticianId = bList[index]["id"].toString();
            });
            Navigator.pop(context, "beauticianChoosed");
            },
            child: Card(
              color: Colors.green,
              elevation: 3,
              shadowColor: Colors.green,
              margin: EdgeInsets.all(8),
              child: ListTile(
                // leading: Padding(
                //   padding: const EdgeInsets.all(2.0),
                //   child: Image.asset(
                //   "images/" +bList[index]["beauticians_details"]["type"].toString() + ".png",
                //   ),
                // ) ,
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      bList[index]["name"],
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  //   Text(
                  //     bList[index]["beautician_details"]["Beautician_type"],
                  //     style: const TextStyle(
                  //       fontSize: 12,
                  //       color: Colors.white,
                  //     ),
                  //   )
                  //   SmoothStarRating(
                  //     rating: 3.5,
                  //     color: Colors.white,
                  //     borderColor: Colors.black,
                  //     allowHalfRating: true,
                  //     starCount: 5,
                  //     size: 15,
                  //
                  //   )
                   ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
