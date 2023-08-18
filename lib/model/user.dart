import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String phoneNbr;

  const User({
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.email,
    required this.phoneNbr,
  });

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
        username: snapshot["username"],
        uid: snapshot["uid"],
        email: snapshot["email"],
        photoUrl: snapshot["profile_image_url"],
        phoneNbr: snapshot["phone_number"]);
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "profile_image_url": photoUrl,
        "phone_number": phoneNbr,
      };
}
