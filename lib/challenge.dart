import 'package:flutter/material.dart';
import 'challenge_timer_screen.dart'; // 👈 Make sure this exists!

class Challenge {
  String title;
  String description;
  String imageUrl;
  bool isCompleted;

  Challenge({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.isCompleted = false,
  });
}

class ChallengeHomePage extends StatefulWidget {
  const ChallengeHomePage({Key? key}) : super(key: key);

  @override
  State<ChallengeHomePage> createState() => _ChallengeHomePageState();
}

class _ChallengeHomePageState extends State<ChallengeHomePage> {
  List<Challenge> challenges = [
    Challenge(
      title: '10K Run',
      description: 'June 1 to June 31, 2021',
      imageUrl: 'https://runkeeper.com/ja/wp-content/uploads/sites/3/2021/10/Make-Running-More-Fun-By-Varying-Your-Route.jpg',
    ),
    Challenge(
      title: '50K Ride',
      description: 'July 1 to July 31, 2021',
      imageUrl: 'https://t3.ftcdn.net/jpg/01/05/07/68/360_F_105076852_bJwYuUFPHQqmCbDiMMOttcWje7e9RwUt.jpg',
    ),
    Challenge(
      title: '5K Swim',
      description: 'August 1 to August 31, 2021',
      imageUrl: 'https://labspa.co.uk/wp-content/uploads/2023/09/swimming-routine-1024x634.jpg',
    ),
  ];

  List<Challenge> filteredChallenges = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredChallenges = challenges;
    searchController.addListener(_filterChallenges);
  }

  void _filterChallenges() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredChallenges = challenges.where((challenge) {
        return challenge.title.toLowerCase().contains(query) ||
            challenge.description.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _addChallenge(Challenge challenge) {
    setState(() {
      challenges.add(challenge);
      _filterChallenges();
    });
  }

  void _deleteChallenge(int index) {
    setState(() {
      challenges.removeAt(index);
      _filterChallenges();
    });
  }

  void _completeChallenge(int index) {
    setState(() {
      challenges[index].isCompleted = true;
      _filterChallenges();
    });
  }

  void _openChallengeDetails(int index) {
    final selectedChallenge = filteredChallenges[index];
    final kmGoal = _extractKmFromTitle(selectedChallenge.title);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeTimerScreen(
          challengeTitle: selectedChallenge.title,
          challengeImageUrl: selectedChallenge.imageUrl,
          goalDistanceKm: kmGoal,
        ),
      ),
    );
  }

  double _extractKmFromTitle(String title) {
    final regex = RegExp(r'^(\d+)K', caseSensitive: false);
    final match = regex.firstMatch(title);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '0') ?? 0.0;
    }
    return 0.0;
  }

  void _showAddChallengeDialog() {
    String title = '';
    String description = '';
    String imageUrl = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Challenge'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Image URL'),
                onChanged: (value) => imageUrl = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (title.isNotEmpty && description.isNotEmpty) {
                  _addChallenge(Challenge(
                    title: title,
                    description: description,
                    imageUrl: imageUrl.isNotEmpty
                        ? imageUrl
                        : 'https://via.placeholder.com/400x200',
                  ));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenge'),
        actions: [
          IconButton(
            onPressed: _showAddChallengeDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Challenge',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredChallenges.length,
              itemBuilder: (context, index) {
                final challenge = filteredChallenges[index];

                return GestureDetector(
                  onTap: () => _openChallengeDetails(index),
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          challenge.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey,
                              child: const Center(child: Icon(Icons.broken_image)),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'CHALLENGE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    challenge.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    challenge.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: challenge.isCompleted ? null : () => _openChallengeDetails(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: challenge.isCompleted ? Colors.grey : Colors.orange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(challenge.isCompleted ? 'Completed' : 'Join Challenge'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChallengeDetailPage extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onJoin;

  const ChallengeDetailPage({
    Key? key,
    required this.challenge,
    required this.onJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenge Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.network(
              challenge.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey,
                  child: const Center(child: Icon(Icons.broken_image)),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              challenge.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              challenge.description,
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Join'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
