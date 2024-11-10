import 'package:flutter/material.dart';
import 'complaint_screen.dart';
import 'admin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'complaint_check_screen.dart';
import 'complaint_check_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedRole = 'Citizen';
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4C9DC2), Color(0xFF3A7CA5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: Text('Home', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Welcome to the Portal',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      Text(
                        'Select your role:',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          items: ['Citizen', 'Admin'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: TextStyle(
                                      fontSize: 18, color: Color(0xFF3A7CA5))),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedRole = newValue!;
                            });
                          },
                          underline: Container(),
                          icon: Icon(Icons.arrow_drop_down,
                              color: Color(0xFF3A7CA5)),
                          isExpanded: true,
                        ),
                      ),
                      SizedBox(height: 40),
                      ElevatedButton(
                        child: Text('Continue', style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Color(0xFF3A7CA5),
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _navigateToNextScreen(),
                      ),
                      SizedBox(height: 40),
                      _buildEmergencySection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencySection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Services',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 15),
          _buildEmergencyButton('Police', Icons.local_police, '100'),
          SizedBox(height: 10),
          _buildEmergencyButton('Ambulance', Icons.local_hospital, '108'),
          SizedBox(height: 10),
          _buildEmergencyButton('Fire', Icons.local_fire_department, '101'),
          SizedBox(height: 10),
          _buildEmergencyButton('Women Helpline', Icons.woman, '1091'),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton(String title, IconData icon, String number) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text('$title - $number', style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () => _showEmergencyCallDialog(title, number),
    );
  }

  void _showEmergencyCallDialog(String service, String number) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Emergency Call'),
          content: Text('Do you want to call $service ($number)?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Call'),
              onPressed: () {
                Navigator.of(context).pop();
                // Add actual call functionality here
                print('Calling $service at $number');
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToNextScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            _selectedRole == 'Citizen' ? ComplaintScreen() : AdminScreen(),
      ),
    );
  }
}
