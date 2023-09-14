import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // adding image to firebase storage
  Future<String> uploadImageToStorage(String childName, File? imageFile) async {
    // creating location to our firebase storage

    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);

    // putting in uint8list format -> Upload task like a future but not future
    final UploadTask uploadTask = ref.putFile(imageFile!);

    // Monitor the upload process
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }

    return null;
  }
}
