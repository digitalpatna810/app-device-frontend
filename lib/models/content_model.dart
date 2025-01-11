import 'package:cloud_firestore/cloud_firestore.dart';

class ContentModel {
  final String id;
  final String userId;
  final String title;
  final String status;
  final DateTime createdAt;

  ContentModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.status,
    required this.createdAt,
  });

  factory ContentModel.fromMap(Map<String, dynamic> data) {
    return ContentModel(
      id: data['id'],
      userId: data['userId'],
      title: data['title'],
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
