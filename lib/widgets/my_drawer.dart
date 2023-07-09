import 'package:flutter/material.dart';
import 'package:shringar1_app/global/global.dart';
import 'package:shringar1_app/splashScreen/splash_screen.dart';
class MyDrawer extends StatefulWidget {
  String? name;
  String? email;

  MyDrawer({this.name, this.email});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child:ListView(
        children: [
          //drawer header
          Container(
            height: 165,
            color: Colors.grey,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 16,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.name.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10,),

                      Text(
                        widget.email.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),

                    ],
                  )
                ],
              ),
            ),


          ),
          const SizedBox(height: 12.0,),
          //drawer body
          GestureDetector(
            onTap: () {

            },
            child: const ListTile(
              leading: Icon(Icons.history, color: Colors.black,),
              title: Text(
                "History",
                style: TextStyle(
                    color: Colors.black
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {

            },
            child: const ListTile(
              leading: Icon(Icons.person, color: Colors.black,),
              title: Text(
                "Visit Profile",
                style: TextStyle(
                    color: Colors.black
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {

            },
            child: const ListTile(
              leading: Icon(Icons.info, color: Colors.black,),
              title: Text(
                "About",
                style: TextStyle(
                    color: Colors.black
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              fAuth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (c)=> MySplashScreen()));

            },
            child: const ListTile(
              leading: Icon(Icons.logout, color: Colors.black,),
              title: Text(
                "Sign out",
                style: TextStyle(
                    color: Colors.black
                ),
              ),
            ),
          ),

        ],
      ),

    );
  }
}
