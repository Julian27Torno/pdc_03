import 'package:flutter/material.dart';
import 'home_screen.dart'; // <-- Import HomeScreen to access recent activities!

class ProfileScreen extends StatelessWidget {
  void _logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, size: 50, color: Colors.grey),
            ),
            SizedBox(height: 12),
            Text(
              "Don Henessy David",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Edit Profile'),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(Icons.show_chart, size: 30, color: Colors.black),
                    SizedBox(height: 4),
                    Text("Progress"),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.history, size: 30, color: Colors.black),
                    SizedBox(height: 4),
                    Text("History"),
                  ],
                ),
              ],
            ),
            SizedBox(height: 32),
            _buildActivitySection("Cycling"),
            SizedBox(height: 24),
            _buildActivitySection("Running"),
            SizedBox(height: 32),
            _buildHistorySection(), // <-- ADD THIS
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStat("Distance", "20 km"),
            _buildStat("Time", "2 hr"),
            _buildStat("Elevation Gain", "40 m"),
          ],
        ),
        SizedBox(height: 12),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text("Graph Placeholder")),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  // 📋 This will show the REAL history data
  Widget _buildHistorySection() {
    final List<Map<String, dynamic>> activities = HomeScreen.recentActivities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Run History",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        if (activities.isEmpty)
          Center(
            child: Text("No history yet.", style: TextStyle(color: Colors.grey)),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                leading: Icon(Icons.directions_run, color: Colors.orange),
                title: Text("Run ${(index + 1)}"),
                subtitle: Text(
                  "${(activity['distance'] as double).toStringAsFixed(2)} km | ${(activity['durationSeconds'] ~/ 60)} min",
                ),
              );
            },
          ),
      ],
    );
  }
}
