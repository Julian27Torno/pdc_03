import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import HomeScreen to save challenge

class ChallengeTimerScreen extends StatefulWidget {
  final String challengeTitle;

  const ChallengeTimerScreen({Key? key, required this.challengeTitle}) : super(key: key);

  @override
  _ChallengeTimerScreenState createState() => _ChallengeTimerScreenState();
}

class _ChallengeTimerScreenState extends State<ChallengeTimerScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _secondsPassed = 0;
  double _distance = 0.0;
  bool _isRunning = true;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRunning) {
        setState(() {
          _secondsPassed++;
          _distance += 0.01; // Simulate 10 meters = 0.01km per second
        });
      }
    });
  }

  void _pauseOrResume() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    });
  }

  void _finishChallenge() {
    _timer.cancel();
    _animationController.dispose();

    HomeScreen.recentChallenges.insert(0, {
      'title': widget.challengeTitle,
      'status': 'In Progress',
      'distance': _distance,
      'durationSeconds': _secondsPassed,
    });

    if (HomeScreen.recentChallenges.length > 5) {
      HomeScreen.recentChallenges.removeLast();
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "$minutes min ${remainingSeconds.toString().padLeft(2, '0')} sec";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.challengeTitle),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              _formatDuration(_secondsPassed),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              "${_distance.toStringAsFixed(2)} km",
              style: const TextStyle(fontSize: 24, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                backgroundColor: Colors.orange,
                heroTag: "pause",
                onPressed: _pauseOrResume,
                child: Icon(
                  _isRunning ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              FloatingActionButton(
                backgroundColor: Colors.green,
                heroTag: "finish",
                onPressed: _finishChallenge,
                child: const Icon(Icons.check, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
