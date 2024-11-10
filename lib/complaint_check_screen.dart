import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Make sure to add this package to your pubspec.yaml

class ComplaintCheckScreen extends StatefulWidget {
  const ComplaintCheckScreen({Key? key, required String phoneNumber})
      : super(key: key);

  @override
  _ComplaintCheckScreenState createState() => _ComplaintCheckScreenState();
}

class _ComplaintCheckScreenState extends State<ComplaintCheckScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot> _complaintsStream;

  @override
  void initState() {
    super.initState();
    _getComplaintsStream();
  }

  Future<void> _getComplaintsStream() async {
    User? user = _auth.currentUser;

    if (user != null) {
      setState(() {
        _complaintsStream = FirebaseFirestore.instance
            .collection('complaints')
            .where('userId', isEqualTo: user.uid)
            .orderBy('date', descending: true)
            .snapshots();
      });
    } else {
      print('User not logged in!');
      // You might want to navigate to a login screen here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Complaints'),
        backgroundColor: Color(0xFF3A7CA5),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _complaintsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No complaints found'));
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return ComplaintCard(
                complaintId: document.id,
                title: data['title'] ?? 'No Title',
                description: data['description'] ?? 'No Description',
                status: data['status'] ?? 'Pending',
                date: data['date']?.toDate() ?? DateTime.now(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final String complaintId;
  final String title;
  final String description;
  final String status;
  final DateTime date;

  const ComplaintCard({
    Key? key,
    required this.complaintId,
    required this.title,
    required this.description,
    required this.status,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    status,
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(status),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(date),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
