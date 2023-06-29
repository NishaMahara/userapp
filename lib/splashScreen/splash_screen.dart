import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shringar1_app/authentication/login_screen.dart';
import 'package:shringar1_app/mainScreens/main_screen.dart';

import '../global/global.dart';

class MySplashScreen extends StatefulWidget
{
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen>
{
  startTimer() {
    Timer(const Duration(seconds: 3), () async
    {
      if(await fAuth.currentUser != null)
       {
           currentFirebaseUser = fAuth.currentUser;
         Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
       }
       else
         {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
         }

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    startTimer();
  }
  @override

  Widget build(BuildContext context)
  {
    return  Container(
      color: Colors.purple,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Image.asset("images/logo1.png"),
            const SizedBox(height: 10,),
            const Text(
              "Beauty at your door step",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),
            ),
          ],

        ),
      ),
    );
  }
}
