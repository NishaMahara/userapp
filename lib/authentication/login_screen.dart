import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shringar1_app/Widgets/progress_dialog.dart';
import 'package:shringar1_app/authentication/signup_screen.dart';
import 'package:shringar1_app/global/global.dart';
import 'package:shringar1_app/splashScreen/splash_screen.dart';





class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
{
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  validateForm()
  {
    if(!emailTextEditingController.text.contains("@")) {
      Fluttertoast.showToast(msg: "Email address is not valid.");
    }

    else if (passwordTextEditingController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Fill the password");
    }
    else {
      LoginUserNow();
    }
  }

  LoginUserNow() async
  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(message: "Processing, Please wait...",);
        }
    );
    final User? firebaseUser =
        (
            await fAuth.signInWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim(),
            ).catchError((msg){
              Navigator.pop(context);
              Fluttertoast.showToast(msg: "Error: " + msg.toString());
            })
        ).user;
    if(firebaseUser != null)
    {

      currentFirebaseUser = firebaseUser;
      Fluttertoast.showToast(msg:"login successful.");
      Navigator.push(context, MaterialPageRoute(builder: (c)=>  const MySplashScreen()));
    }
    else
    {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error occur.");
    }

  }

  @override
  Widget build(BuildContext context)
  {

    return Scaffold(
      backgroundColor: Colors.black,
      body:SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [

              const SizedBox(height: 30,),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/logo1.png"),
              ),

              const SizedBox(height: 10,),
              Text(
                "Login as User ",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,

                ),
              ),
              TextField(
                controller: emailTextEditingController,
                style: TextStyle(
                    color: Colors.grey
                ),
                decoration:  const InputDecoration(
                    labelText: "Email",
                    hintText: "abc@gmail.com",

                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color:Colors.grey),
                    ),

                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color:Colors.grey),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    )
                ),

              ),
              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                style: TextStyle(
                    color: Colors.grey
                ),
                decoration:  const InputDecoration(
                  labelText: "Password",
                  hintText: "*********",

                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color:Colors.grey),
                  ),

                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color:Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

              ),

              const SizedBox(height: 20,),

              ElevatedButton(
                onPressed: ()
                {

                  validateForm();

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                ),
                child:const Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 18,
                  ),
                ),
              ),

              TextButton(
                child: const Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder:(c)=>SignUpScreen()));
                },
              )
            ],

          ),
        ),

      ),
    );
  }
}
