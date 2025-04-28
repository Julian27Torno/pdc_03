import 'package:finalproj/profile.dart';
import 'package:flutter/material.dart';
import 'start_tracking_screen.dart';
import 'feed.dart';
import 'challenge.dart';

class HomeScreen extends StatefulWidget {
  final double? distance;
  final int? durationSeconds;
  final String? challengeTitle;
  final String? challengeImageUrl;

  HomeScreen({this.distance, this.durationSeconds, this.challengeTitle, this.challengeImageUrl});

  static List<Map<String, dynamic>> recentActivities = [];
  static List<Map<String, dynamic>> recentChallenges = [];

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    if (widget.distance != null && widget.durationSeconds != null) {
      HomeScreen.recentActivities.insert(0, {
        'distance': widget.distance,
        'durationSeconds': widget.durationSeconds,
        'sport': StartTrackingScreen.lastSelectedSport ?? 'Running',
      });

      if (HomeScreen.recentActivities.length > 5) {
        HomeScreen.recentActivities.removeLast();
      }
    }

    if (widget.challengeTitle != null && widget.challengeImageUrl != null) {
      HomeScreen.recentChallenges.insert(0, {
        'title': widget.challengeTitle!,
        'status': 'In Progress',
        'imageUrl': widget.challengeImageUrl!,
      });

      if (HomeScreen.recentChallenges.length > 5) {
        HomeScreen.recentChallenges.removeLast();
      }
    }

    _pages = [
      HomeContent(
        recentActivities: HomeScreen.recentActivities,
        recentChallenges: HomeScreen.recentChallenges,
      ),
      StartTrackingScreen(),
      ChallengeHomePage(),
      FeedPage(),
      ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_fill), label: "Track"),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: "Challenge"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Friends"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final List<Map<String, dynamic>> recentActivities;
  final List<Map<String, dynamic>> recentChallenges;

  const HomeContent({
    required this.recentActivities,
    required this.recentChallenges,
  });

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "$minutes min ${remainingSeconds.toString().padLeft(2, '0')} sec";
  }

  String _formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      int meters = (distanceKm * 1000).round();
      return "$meters meters";
    } else {
      return "${distanceKm.toStringAsFixed(2)} km";
    }
  }

  Icon _getSportIcon(String? sport) {
    switch (sport) {
      case "Running":
        return Icon(Icons.directions_run, color: Colors.orange);
      case "Cycling":
        return Icon(Icons.directions_bike, color: Colors.orange);
      case "Swimming":
        return Icon(Icons.pool, color: Colors.orange);
      default:
        return Icon(Icons.directions_run, color: Colors.orange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            "Recent Activity",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (recentActivities.isEmpty)
            const Center(child: Text("No recent activity yet", style: TextStyle(color: Colors.grey)))
          else
            ...recentActivities.map((activity) => ListTile(
              leading: _getSportIcon(activity['sport']),
              title: Text("New ${activity['sport'] ?? 'Run'}"),
              subtitle: Text(
                "${_formatDistance(activity['distance'] as double)} | ${_formatDuration(activity['durationSeconds'] as int)}",
              ),
            )),
          const SizedBox(height: 24),

          const Text(
            "Recent Challenges",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (recentChallenges.isEmpty)
            const Center(child: Text("No challenge joined yet", style: TextStyle(color: Colors.grey)))
          else
            ...recentChallenges.map((challenge) {
              final title = challenge['title'] ?? 'Unknown Challenge';
              final status = challenge['status'] ?? 'In Progress';
              final imageUrl = challenge['imageUrl'] ?? 'https://via.placeholder.com/400x200';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 150,
                            color: Colors.grey,
                            child: const Center(child: Icon(Icons.broken_image)),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "RUNNING",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                status,
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Add navigation to challenge timer or details
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Detail'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
