import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatefulWidget {
  final String? complaintId;

  FeedbackScreen({this.complaintId});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackData = {'feedback': '', 'category': 'General'};
  List<String> _communityNews = [];

  static const List<String> categories = [
    'General',
    'App Functionality',
    'User Interface',
    'Performance',
    'Feature Request',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _fetchCommunityNews();
  }

  Future<void> _fetchCommunityNews() async {
    try {
      final newsSnapshot = await FirebaseFirestore.instance
          .collection('community_news')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      setState(() {
        _communityNews =
            newsSnapshot.docs.map((doc) => doc['content'] as String).toList();
      });
    } catch (error) {
      print('Error fetching community news: $error');
    }
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await FirebaseFirestore.instance.collection('feedback').add({
          ..._feedbackData,
          'timestamp': FieldValue.serverTimestamp(),
          'complaintId':
              widget.complaintId, // Add the complaint ID if available
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feedback submitted successfully')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF3A7CA5),
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
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    AppBar().preferredSize.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.complaintId != null)
                              // ... [your Complaint ID section]
                              _buildCommunityNewsSection(),
                            SizedBox(height: 20),
                            _buildFeedbackForm(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityNewsSection() {
    return Card(
      color: Colors.white.withOpacity(0.8), // Semi-transparent white card
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Community News',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A7CA5))), // Darker blue heading
            SizedBox(height: 10),
            _communityNews.isEmpty
                ? Center(
                    child:
                        CircularProgressIndicator()) // Center loading indicator
                : Column(
                    children: _communityNews
                        .map((news) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text('• $news',
                                  style: TextStyle(color: Colors.grey[700])),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return Card(
      color: Colors.white.withOpacity(0.8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Feedback',
                  labelStyle: TextStyle(color: Color(0xFF3A7CA5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF3A7CA5), width: 2),
                  ),
                ),
                maxLines: 5,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your feedback' : null,
                onSaved: (value) => _feedbackData['feedback'] = value!,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _feedbackData['category'],
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Color(0xFF3A7CA5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF3A7CA5), width: 2),
                  ),
                ),
                items: categories
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _feedbackData['category'] = value!),
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3A7CA5),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Submit Feedback',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
