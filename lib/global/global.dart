
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shringar1_app/models/user_model.dart';



final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
List bList = []; //beauticianKeys Info