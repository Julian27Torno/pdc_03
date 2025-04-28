import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SwimmingTimerScreen extends StatefulWidget {
  final double metersPerLap;
  final double speedMultiplier; // 0.5, 1.0, or 2.0

  const SwimmingTimerScreen({
    Key? key,
    required this.metersPerLap,
    required this.speedMultiplier,
  }) : super(key: key);

  @override
  _SwimmingTimerScreenState createState() => _SwimmingTimerScreenState();
}

class _SwimmingTimerScreenState extends State<SwimmingTimerScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _secondsPassed = 0;
  double _distanceInMeters = 0.0;
  int _laps = 0;
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

          // 1.0 m/s Normal, adjust based on selected speed
          double baseSpeed = 1.0; // Normal human swim pace ~1 m/s
          double currentSpeed = baseSpeed * widget.speedMultiplier;

          _distanceInMeters += currentSpeed;

          _laps = (_distanceInMeters / widget.metersPerLap).floor();
        });
      }
    });
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getSpeedLabel() {
    if (widget.speedMultiplier == 0.5) return "Slow";
    if (widget.speedMultiplier == 2.0) return "Fast";
    return "Normal";
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

  void _finish() {
    _timer.cancel();
    _animationController.dispose();

    // Return the result back!
    Navigator.pop(context, {
      'distanceInMeters': _distanceInMeters,
      'durationSeconds': _secondsPassed,
    });
  }


  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swimming Timer'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: TimerPainter(
                      animation: _animationController,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.blue,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _distanceInMeters.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('meters', style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat("03'00\"", "Avg Pace"),
                _buildStat("120 BPM", "Heart Rate"),
                _buildStat(_formatDuration(_secondsPassed), "Duration"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Laps: $_laps",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Speed: ${_getSpeedLabel()}",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                heroTag: "done",
                onPressed: _finish,
                child: const Icon(Icons.check, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class TimerPainter extends CustomPainter {
  TimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);

    paint.color = color;
    double progress = animation.value;
    canvas.drawArc(
      Offset.zero & size,
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
