import 'package:firebase_database/firebase_database.dart';

class UserModel{
  String? email;
  String? id;
  String? name;
  String? password;
  String? phone;
  UserModel({this.phone, this.name, this.id, this.email,});
  UserModel.fromSnapshot(DataSnapshot snap)
  {

    email = (snap.value as dynamic)["email"];
    name = (snap.value as dynamic)["name"];
    password = (snap.value as dynamic)["password"];
    phone = (snap.value as dynamic)["phone"];
    id = snap.key;
  }
}
