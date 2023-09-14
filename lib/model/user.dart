import 'package:cloud_firestore/cloud_firestore.dart';

class UserApp {
  final String email;
  final String uid;
  final String photoUrl;
  final String firstName;
  final String lastName;
  final String phoneNbr;

  const UserApp({
    required this.lastName,
    required this.firstName,
    required this.uid,
    required this.photoUrl,
    required this.email,
    required this.phoneNbr,
  });

  static UserApp fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return UserApp(
        firstName: snapshot["first_name"],
        lastName: snapshot["last_name"],
        uid: snapshot["uid"],
        email: snapshot["email"],
        photoUrl: snapshot["profile_image_url"],
        phoneNbr: snapshot["phone_number"]);
  }

  Map<String, dynamic> toJson() => {
        "last_name": lastName,
        "first_name": firstName,
        "uid": uid,
        "email": email,
        "profile_image_url": photoUrl,
        "phone_number": phoneNbr,
      };
}
