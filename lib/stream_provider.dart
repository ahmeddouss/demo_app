import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreammProvider {
  //collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  final uid = FirebaseAuth.instance.currentUser!.uid;

  //get user doc stream
  Stream<DocumentSnapshot<Object?>?> get userData {
    return userCollection.doc(uid).snapshots();
  }
}
