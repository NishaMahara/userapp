import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sajiloshringar_app/authentication/login_screen.dart';
import 'package:sajiloshringar_app/authentication/signup_screen.dart';
import 'package:sajiloshringar_app/mainScreens/main_screen.dart';

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
            CurrentFirebaseUser = fAuth.currentUser;
         Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));

       }
       else
         {
         Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen())));
         }

      Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
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
      color: Colors.purpleAccent,
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
