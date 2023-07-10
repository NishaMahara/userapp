import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../global/global.dart';
class SelectNearestActiveBeauticiansScreen extends StatefulWidget {
  const SelectNearestActiveBeauticiansScreen({super.key});

  @override
  State<SelectNearestActiveBeauticiansScreen> createState() => _SelectNearestActiveBeauticiansScreenState();
}

class _SelectNearestActiveBeauticiansScreenState extends State<SelectNearestActiveBeauticiansScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Nearest Online Beauticians",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          leading: IconButton(
              icon: const Icon(
                  Icons.close, color: Colors.white
              ),
              onPressed: () {
                //remove the ride request from database
                SystemNavigator.pop();
              }
          )

      ),
      body: ListView.builder(
        itemCount: bList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            color: Colors.grey,
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
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                //   Text(
                //     bList[index]["beautician_details"]["Beautician_type"],
                //     style: const TextStyle(
                //       fontSize: 12,
                //       color: Colors.white,
                //     ),
                //   )
                  SmoothStarRating(
                    rating: 3.5,
                    color: Colors.black,
                    borderColor: Colors.black,
                    allowHalfRating: true,
                    starCount: 5,
                    size: 15,

                  )
                 ],
              ),
            ),
          );
        },
      ),
    );
  }
}
