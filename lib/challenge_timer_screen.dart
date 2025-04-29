import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class ChallengeTimerScreen extends StatefulWidget {
  final String challengeTitle;
  final String challengeImageUrl;
  final double goalDistanceKm;
  final double initialDistance;
  final int initialSeconds;

  const ChallengeTimerScreen({
    Key? key,
    required this.challengeTitle,
    required this.challengeImageUrl,
    required this.goalDistanceKm,
    this.initialDistance = 0.0,
    this.initialSeconds = 0,
  }) : super(key: key);

  @override
  _ChallengeTimerScreenState createState() => _ChallengeTimerScreenState();
}

class _ChallengeTimerScreenState extends State<ChallengeTimerScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late int _secondsPassed;
  late double _distance;
  bool _isRunning = true;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _distance = widget.initialDistance;
    _secondsPassed = widget.initialSeconds;
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
          _distance += 0.01;
          _saveProgress(); // ✅ Save every second
          if (_distance >= widget.goalDistanceKm) {
            _completeChallenge();
          }
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
        _saveProgress(); // ✅ Save when paused
      }
    });
  }

  void _finishChallenge() {
    _timer.cancel();
    _animationController.dispose();
    _saveProgress();
    Navigator.pop(context);
  }

  void _completeChallenge() {
    setState(() {
      _isRunning = false;
    });
    _finishChallenge();
  }

  void _saveProgress() {
    // Remove old challenge with same title
    HomeScreen.recentChallenges.removeWhere((challenge) => challenge['title'] == widget.challengeTitle);

    HomeScreen.recentChallenges.insert(0, {
      'title': widget.challengeTitle,
      'imageUrl': widget.challengeImageUrl,
      'status': _distance >= widget.goalDistanceKm ? 'Finished' : 'In Progress',
      'distanceKm': widget.goalDistanceKm,
      'progressKm': _distance,
      'durationSeconds': _secondsPassed,
    });

    if (HomeScreen.recentChallenges.length > 5) {
      HomeScreen.recentChallenges.removeLast();
    }
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
    double progress = (_distance / widget.goalDistanceKm).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.challengeTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: Image.network(
              widget.challengeImageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey,
                  child: const Center(child: Icon(Icons.broken_image)),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            color: Colors.orange,
            minHeight: 10,
          ),
          const SizedBox(height: 10),
          Text(
            "${_distance.toStringAsFixed(2)} km / ${widget.goalDistanceKm} km",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            _formatDuration(_secondsPassed),
            style: const TextStyle(fontSize: 24),
          ),
          const Spacer(),
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
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
