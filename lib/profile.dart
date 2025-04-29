import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'home_screen.dart';
import 'package:intl/intl.dart'; // For formatting weekday names

class ProfileScreen extends StatelessWidget {
  void _logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final allActivities = HomeScreen.recentActivities;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') _logout(context);
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, size: 50, color: Colors.grey),
            ),
            SizedBox(height: 12),
            Text("Don Henessy David", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text('Edit Profile'),
            ),
            SizedBox(height: 24),

            _buildActivitySection("Running", allActivities),
            SizedBox(height: 24),
            _buildActivitySection("Cycling", allActivities),
            SizedBox(height: 24),
            _buildActivitySection("Swimming", allActivities),

            SizedBox(height: 32),
            _buildHistorySection(allActivities),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(String sport, List<Map<String, dynamic>> activities) {
    final filtered = activities.where((a) => a['sport'] == sport).toList();
    double totalDistance = filtered.fold(0.0, (sum, a) => sum + (a['distance'] ?? 0.0));
    int totalTime = filtered.fold(0, (sum, a) => sum + ((a['durationSeconds'] ?? 0) as int));

    // Initialize distances for each weekday
    final Map<String, double> distancesPerDay = {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };

    // Simulate assigning each activity randomly to a weekday (for now)
    // You can improve later by saving actual dates
    for (var i = 0; i < filtered.length; i++) {
      final weekday = DateFormat('EEE').format(DateTime.now().subtract(Duration(days: i % 7)));
      distancesPerDay[weekday] = (distancesPerDay[weekday] ?? 0) + (filtered[i]['distance'] ?? 0.0);
    }

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sport, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStat("Distance", "${totalDistance.toStringAsFixed(2)} km"),
            _buildStat("Time", _formatDuration(totalTime)),
          ],
        ),
        SizedBox(height: 12),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: filtered.isEmpty
              ? Center(child: Text("No data"))
              : BarChart(
            BarChartData(
              barGroups: List.generate(days.length, (index) {
                final dist = distancesPerDay[days[index]] ?? 0.0;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: double.parse(dist.toStringAsFixed(2)),
                      width: 16,
                      color: Colors.orange,
                    )
                  ],
                );
              }),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < days.length) {
                        return Text(days[value.toInt()], style: TextStyle(fontSize: 10));
                      }
                      return Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
            ),
          ),
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

  Widget _buildHistorySection(List<Map<String, dynamic>> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        if (activities.isEmpty)
          Center(child: Text("No history yet.", style: TextStyle(color: Colors.grey)))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              final sport = activity['sport'] ?? 'Run';
              final icon = sport == 'Running'
                  ? Icons.directions_run
                  : sport == 'Cycling'
                  ? Icons.directions_bike
                  : Icons.pool;
              return ListTile(
                leading: Icon(icon, color: Colors.orange),
                title: Text("$sport ${(index + 1)}"),
                subtitle: Text(
                  "${(activity['distance'] as double).toStringAsFixed(2)} km | ${_formatDuration(activity['durationSeconds'])}",
                ),
              );
            },
          ),
      ],
    );
  }

  String _formatDuration(dynamic seconds) {
    if (seconds == null) return "0 min 00 sec";
    int totalSeconds = (seconds as int);
    int minutes = totalSeconds ~/ 60;
    int remainingSeconds = totalSeconds % 60;
    return "$minutes min ${remainingSeconds.toString().padLeft(2, '0')} sec";
  }
}
