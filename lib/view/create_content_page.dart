import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import '../services/firebase_storage_service.dart';

class CreateContentPage extends StatefulWidget {
  @override
  _CreateContentPageState createState() => _CreateContentPageState();
}

class _CreateContentPageState extends State<CreateContentPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'Medical';
  String _selectedFileType = 'image';
  File? _selectedFile;
  String? _textContent;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters long';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters long';
    }
    return null;
  }

  Future<void> _checkPermissionAndPickFile() async {
    try {
      PermissionStatus status;
      if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();
        status = androidVersion >= 33
            ? await Permission.photos.request()
            : await Permission.storage.request();
      } else {
        status = await Permission.photos.request();
      }

      if (status.isGranted) {
        switch (_selectedFileType) {
          case 'image':
            await _pickImage();
            break;
          case 'video':
            await _pickVideo();
            break;
          case 'pdf':
            await _pickPDF();
            break;
          case 'text':
            _enterTextContent();
            break;
        }
      } else if (status.isPermanentlyDenied) {
        _showPermissionDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage != null) {
      setState(() => _selectedFile = File(pickedImage.path));
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedVideo = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 1),
    );

    if (pickedVideo != null) {
      final file = File(pickedVideo.path);
      if (file.lengthSync() > 50 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video size exceeds 50MB')),
        );
      } else {
        setState(() => _selectedFile = file);
      }
    }
  }

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.size <= 5 * 1024 * 1024) {
      setState(() => _selectedFile = File(result.files.single.path!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF file size exceeds 5MB')),
      );
    }
  }

  void _enterTextContent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Text Content'),
        content: TextFormField(
          maxLines: 5,
          onChanged: (value) => _textContent = value,
          decoration: const InputDecoration(
            hintText: 'Enter your text content here',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_textContent == null || _textContent!.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Text content is required')),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 0;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Storage permission is required to select files. Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => openAppSettings(),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitContent() async {
    if (_formKey.currentState!.validate() && (_selectedFile != null || _textContent != null)) {
      setState(() => _isLoading = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('User not logged in');

        final contentId = DateTime.now().millisecondsSinceEpoch.toString();
        String uploadedUrl = '';

        switch (_selectedFileType) {
          case 'image':
            uploadedUrl = await FirebaseStorageService.uploadContentImage(contentId, _selectedFile!);
            break;
          case 'video':
            uploadedUrl = await FirebaseStorageService.uploadContentVideo(contentId, _selectedFile!);
            break;
          case 'pdf':
            uploadedUrl = await FirebaseStorageService.uploadContentPDF(contentId, _selectedFile!);
            break;
          case 'text':
            uploadedUrl = await FirebaseStorageService.uploadContentText(contentId, _textContent!);
            break;
        }

        final content = {
          'id': contentId,
          'title': _titleController.text.trim(),
          'category': _category,
          'description': _descriptionController.text.trim(),
          'fileType': _selectedFileType,
          'fileUrl': uploadedUrl,
          'userId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance.collection('content').doc(contentId).set(content);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Success!'),
            content: const Text('Your content has been submitted successfully.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back
                },
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting content: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true, // Extend gradient behind the AppBar
      appBar: AppBar(
        title: const Text('Create Content'),
        elevation: 0,
        backgroundColor: Colors.transparent, // Make AppBar transparent
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade900,
              Colors.purple.shade800,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: kToolbarHeight + 24, // Account for AppBar height
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Content',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'Enter content title',
                  validator: _validateTitle,
                  prefixIcon: Icons.title,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Enter content description',
                  validator: _validateDescription,
                  maxLines: 4,
                  prefixIcon: Icons.description,
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  value: _category,
                  label: 'Category',
                  items: ['Medical', 'Engineering', 'News', 'Gallery'],
                  onChanged: (value) => setState(() => _category = value!),
                  icon: Icons.category,
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  value: _selectedFileType,
                  label: 'Content Type',
                  items: ['image', 'video', 'pdf', 'text'],
                  onChanged: (value) => setState(() => _selectedFileType = value!),
                  icon: Icons.attachment,
                ),
                const SizedBox(height: 24),
                _buildFileUploadArea(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.white) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(
            value: item,
            child: Text(
              item.toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ))
              .toList(),
          onChanged: onChanged,
          dropdownColor: Colors.indigo.shade800,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildFileUploadArea() {
    return GestureDetector(
      onTap: _checkPermissionAndPickFile,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getFileTypeIcon(),
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFileType == 'text'
                  ? (_textContent ?? 'Enter Text Content')
                  : (_selectedFile != null
                  ? 'File Selected: ${_selectedFile!.path.split('/').last}'
                  : 'Click to Select ${_selectedFileType.toUpperCase()}'),
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileTypeIcon() {
    switch (_selectedFileType) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_library;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'text':
        return Icons.text_fields;
      default:
        return Icons.attach_file;
    }
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitContent,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          'Submit Content',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}