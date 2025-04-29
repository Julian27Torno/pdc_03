import 'package:flutter/material.dart';

class TrackingSummaryScreen extends StatelessWidget {
  final double distanceKm;
  final int durationSeconds;
  final String sport;

  const TrackingSummaryScreen({
    Key? key,
    required this.distanceKm,
    required this.durationSeconds,
    required this.sport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$sport Finished"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text("${distanceKm.toStringAsFixed(2)}", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  Text("kilometers", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(_calculatePace(distanceKm, durationSeconds), "Pace"),
                _buildSummaryItem(_formatDuration(durationSeconds), "Time"),
                _buildSummaryItem("120 bpm", "Heart Rate"),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem("50 ft", "Elevation"),
                _buildSummaryItem("440", "Calories"),
              ],
            ),
            SizedBox(height: 30),

            if (sport != "Swimming") ...[
              Text("Route Map", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(child: Text("[Map Placeholder]")),
              ),
              SizedBox(height: 30),
            ],

            Text("Capture", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => Container(
                color: Colors.grey[300],
                child: Center(child: Icon(Icons.image, size: 40)),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: Text("Back to Home", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "$minutes min ${remainingSeconds.toString().padLeft(2, '0')} sec";
  }

  String _calculatePace(double km, int seconds) {
    if (km == 0) return "--";
    double paceSeconds = seconds / km;
    int min = paceSeconds ~/ 60;
    int sec = (paceSeconds % 60).round();
    return "$min'${sec.toString().padLeft(2, '0')}\"";
  }
}
