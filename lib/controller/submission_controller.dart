import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubmissionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedFilter = 'All'; // Default filter
  List<Map<String, dynamic>> _submissions = [];
  bool _isLoading = false;

  String get selectedFilter => _selectedFilter;
  List<Map<String, dynamic>> get submissions => _submissions;
  bool get isLoading => _isLoading;

  // Fetch submissions based on the selected filter
  Future<void> fetchSubmissions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      Query query = _firestore
          .collection('content')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true);

      if (_selectedFilter != 'All') {
        query = query.where('status', isEqualTo: _selectedFilter.toLowerCase());
      }

      final snapshot = await query.get();
      debugPrint('Fetched ${snapshot.docs.length} submissions'); // Debug log

      _submissions = snapshot.docs.map((doc) {
        final data = doc.data();
        if (data == null) return null; // Skip null data
        debugPrint('Submission data: $data'); // Debug log
        return data;
      }).where((data) => data != null).cast<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error fetching submissions: $e'); // Debug log
      // Optionally, show a SnackBar or other UI feedback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update the selected filter and fetch submissions
  void setFilter(String filter) {
    _selectedFilter = filter;
    fetchSubmissions();
  }
}