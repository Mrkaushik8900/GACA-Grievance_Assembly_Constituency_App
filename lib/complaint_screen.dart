import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'feedback_screen.dart';

class ComplaintScreen extends StatefulWidget {
  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _complaintData = {
    'name': '',
    'email': '',
    'complaint': '',
    'category': 'Infrastructure',
    'imageUrl': '',
    'videoUrl': '',
  };

  File? _image;
  File? _video;
  final picker = ImagePicker();
  bool _isLoading = false;

  static const List<String> categories = [
    'Infrastructure',
    'Public Services',
    'Health',
    'Education',
    'Environment',
    'Other'
  ];

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _getVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _video = File(pickedFile.path);
      }
    });
  }

  Future<String> _uploadFile(File file, String folder) async {
    // ignore: unnecessary_null_comparison
    if (file == null) return '';

    final fileName = path.basename(file.path);
    final firebaseStorageRef =
        FirebaseStorage.instance.ref().child('$folder/$fileName');

    await firebaseStorageRef.putFile(file);
    return await firebaseStorageRef.getDownloadURL();
  }

  void _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String imageUrl = await _uploadFile(_image!, 'complaint_images');
      String videoUrl = await _uploadFile(_video!, 'complaint_videos');
      _complaintData['imageUrl'] = imageUrl;
      _complaintData['videoUrl'] = videoUrl;

      // Generate a unique complaint ID
      String complaintId =
          FirebaseFirestore.instance.collection('complaints').doc().id;

      FirebaseFirestore.instance.collection('complaints').doc(complaintId).set({
        ..._complaintData,
        'complaintId': complaintId,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Complaint submitted successfully. ID: $complaintId')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => FeedbackScreen(complaintId: complaintId)),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit complaint: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Register Complaint', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3A7CA5), Color(0xFF81C3D7)],
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3A7CA5), Color(0xFF4C9DC2)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextFormField('Name', 'name'),
                        SizedBox(height: 16),
                        _buildTextFormField('Email', 'email'),
                        SizedBox(height: 16),
                        _buildTextFormField('Complaint', 'complaint',
                            maxLines: 5),
                        SizedBox(height: 16),
                        _buildDropdownField('Category', 'category', categories),
                        SizedBox(height: 24),
                        Text(
                          'Add Image/Video (Optional)',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _image == null
                                  ? _buildPlaceholder('No image selected')
                                  : Image.file(_image!, height: 150),
                            ),
                            SizedBox(width: 10),
                            _buildIconButton(Icons.camera_alt, _getImage),
                            SizedBox(width: 10),
                            _buildIconButton(Icons.videocam, _getVideo),
                          ],
                        ),
                        SizedBox(height: 10),
                        if (_video != null)
                          Text('Video selected: ${path.basename(_video!.path)}',
                              style: TextStyle(color: Colors.white60)),
                        SizedBox(height: 30),
                        ElevatedButton(
                          child: Text('Send Complaint',
                              style: TextStyle(fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Color(0xFF3A7CA5),
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _submitComplaint,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPlaceholder(String text) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, String field, {int maxLines = 1}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      maxLines: maxLines,
      validator: (value) => value!.isEmpty ? 'Please enter your $field' : null,
      onSaved: (value) => _complaintData[field] = value!,
    );
  }

  Widget _buildDropdownField(String label, String field, List<String> items) {
    return DropdownButtonFormField<String>(
      value: _complaintData[field],
      decoration: InputDecoration(labelText: label),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) => setState(() => _complaintData[field] = value!),
      validator: (value) => value == null ? 'Please select a $field' : null,
    );
  }
}
