import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/content_model.dart';
//
// class FirestoreService {
//   static final FirebaseStorage _storage = FirebaseStorage.instance;
//   final CollectionReference contentCollection =
//       FirebaseFirestore.instance.collection('content');
//
//   Future<void> submitContent(ContentModel content) async {
//     await contentCollection.doc(content.id).set(content.toMap());
//   }
//
//   Stream<List<ContentModel>> getUserSubmissions(String userId) {
//     return contentCollection.where('userId', isEqualTo: userId).snapshots().map(
//         (snapshot) => snapshot.docs
//             .map((doc) =>
//                 ContentModel.fromMap(doc.data() as Map<String, dynamic>))
//             .toList());
//   }
//
// }






class FirestoreService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference contentCollection =
  FirebaseFirestore.instance.collection('content');

  Future<void> submitContent(ContentModel content) async {
    try {
      // Add content to Firestore, Firestore will auto-generate the ID
      await contentCollection.add(content.toMap());
    } catch (e) {
      print("Error submitting content: $e");
    }
  }


  Stream<List<ContentModel>> getUserSubmissions(String userId) {
    return contentCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) =>
        ContentModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }
}
