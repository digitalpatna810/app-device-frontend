import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<void> updateUserProfile(String name, String email) async {
    User? user = auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.updateEmail(email);
      await firestore.collection('users').doc(user.uid).update({
        'name': name,
        'email': email,
      });
    }
  }

  static Future<void> changeUserPassword(
      String oldPassword, String newPassword) async {
    User? user = auth.currentUser;
    if (user != null) {
      String email = user.email!;
      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: oldPassword);
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    }
  }
}
