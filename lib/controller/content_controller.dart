import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/content_model.dart';
import '../services/firestore_service.dart';

// class ContentProvider extends ChangeNotifier {
//   final FirestoreService _firestoreService = FirestoreService();
//   List<ContentModel> _submissions = [];
//
//   List<ContentModel> get submissions => _submissions;
//
//   Future<void> fetchSubmissions(String userId) async {
//     _firestoreService.getUserSubmissions(userId).listen((contentList) {
//       _submissions = contentList;
//       notifyListeners();
//     });
//   }
//
//   Future<void> submitContent(ContentModel content) async {
//     await _firestoreService.submitContent(content);
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart';

class ContentProvider with ChangeNotifier {
  List<ContentModel> _submissions = [];
  bool _isLoading = false;

  List<ContentModel> get submissions => _submissions;
  bool get isLoading => _isLoading;

  Future<void> fetchSubmissions(String userId) async {
    try {
      _isLoading = true;
      notifyListeners(); // Notify listeners before starting the async operation

      final snapshot = await FirebaseFirestore.instance
          .collection('content')
          .where('userId', isEqualTo: userId)
          .get();

      _submissions = snapshot.docs
          .map((doc) => ContentModel.fromMap(doc.data()))
          .toList();

      _isLoading = false;
      notifyListeners(); // Notify listeners after the async operation is complete
    } catch (e) {
      _isLoading = false;
      notifyListeners(); // Notify listeners in case of an error
      print("Error fetching submissions: $e");
    }
  }
}