
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shringar1_app/models/user_model.dart';



final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
List bList = []; //beauticianKeys Info
String? chosenBeauticianId="";
String cloudMessagingServerToken = "AAAAuhDBp9g:APA91bGdnjo6SoFsOIzrPzhCgQOj7zFDw73FzKzu81bFJDHRzOLVTHPJW0fPTc-1yr5do49lYPZEG5dwFvDyV-dU5EqOCCzVrVFXt3finmvBdF9r5c0FigjUohHT8znkFOaetw9elma2";
String userHomeLocation = "";
