import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'complaint_list_screen.dart';

class AdminScreen extends StatelessWidget {
  final int registeredComplaints = 16;
  final int pendingComplaints = 10;
  final int resolvedComplaints = 8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFFB2EBF2)
            ], // Light blue gradient
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 65.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Admin Dashboard',
                    style: TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF81D4FA),
                          Color(0xFF4FC3F7)
                        ], // Slightly darker blue gradient for app bar
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOverviewCards(),
                      SizedBox(height: 24),
                      Text(
                        'Complaint Distribution',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      SizedBox(height: 16),
                      _buildDashboardChart(),
                      SizedBox(height: 24),
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      SizedBox(height: 16),
                      _buildQuickActionButtons(context),
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

  Widget _buildOverviewCards() {
    return Row(
      children: [
        Expanded(
            child: _buildOverviewCard(
                'Registered', registeredComplaints, Colors.blue)),
        SizedBox(width: 16),
        Expanded(
            child: _buildOverviewCard(
                'Pending', pendingComplaints, Colors.orange)),
        SizedBox(width: 16),
        Expanded(
            child: _buildOverviewCard(
                'Resolved', resolvedComplaints, Colors.green)),
      ],
    );
  }

  Widget _buildOverviewCard(String title, int count, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardChart() {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              color: Colors.blue,
              value: registeredComplaints.toDouble(),
              title: 'Registered',
              radius: 100,
              titleStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            PieChartSectionData(
              color: Colors.orange,
              value: pendingComplaints.toDouble(),
              title: 'Pending',
              radius: 100,
              titleStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            PieChartSectionData(
              color: Colors.green,
              value: resolvedComplaints.toDouble(),
              title: 'Resolved',
              radius: 100,
              titleStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          context,
          'View Registered Complaints',
          Icons.list_alt,
          Colors.blue,
          () => _navigateToComplaintList(context, 'registered'),
        ),
        SizedBox(height: 16),
        _buildActionButton(
          context,
          'Manage Pending Complaints',
          Icons.pending_actions,
          Colors.orange,
          () => _navigateToComplaintList(context, 'pending'),
        ),
        SizedBox(height: 16),
        _buildActionButton(
          context,
          'Review Resolved Complaints',
          Icons.check_circle_outline,
          Colors.green,
          () => _navigateToComplaintList(context, 'resolved'),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(title, style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _navigateToComplaintList(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComplaintListScreen(category: category),
      ),
    );
  }
}
