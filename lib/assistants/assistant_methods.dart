import 'package:firebase_database/firebase_database.dart';
import 'package:shringar1_app/global/global.dart';
import 'package:shringar1_app/models/user_model.dart';

class AssistantMethods {
  static void readCurrentOnlineUserInfo() async
  {
    currentFirebaseUser = fAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid);
    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo=UserModel.fromSnapshot(snap.snapshot);

      }
    });
  }
}