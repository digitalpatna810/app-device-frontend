import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile images
  static Future<String> uploadProfileImage(String userId, File imageFile) async {
    final ref = _storage.ref().child('profile_images/$userId');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Upload images for content
  static Future<String> uploadContentImage(String contentId, File imageFile) async {
    final ref = _storage.ref().child('content_images/$contentId');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Upload PDFs
  static Future<String> uploadContentPDF(String contentId, File pdfFile) async {
    if (pdfFile.lengthSync() > 5 * 1024 * 1024) {
      throw Exception("PDF file size exceeds 5MB");
    }
    final ref = _storage.ref().child('content_pdfs/$contentId');
    await ref.putFile(pdfFile);
    return await ref.getDownloadURL();
  }

  // Upload videos
  static Future<String> uploadContentVideo(String contentId, File videoFile) async {
    final ref = _storage.ref().child('content_videos/$contentId');
    final uploadTask = await ref.putFile(videoFile);
    final metadata = await uploadTask.ref.getMetadata();
    if (metadata.size! > 1024 * 1024 * 50) {
      throw Exception("Video size exceeds 50MB");
    }
    return await ref.getDownloadURL();
  }

  // Upload text/newsletter/articles
  static Future<String> uploadContentText(String contentId, String textContent) async {
    final ref = _storage.ref().child('content_texts/$contentId.txt');
    final data = textContent.codeUnits;
    final task = await ref.putData(Uint8List.fromList(data));
    return await task.ref.getDownloadURL();
  }
}
