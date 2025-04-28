import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'home_screen.dart';

class TrackingScreen extends StatefulWidget {
  final String sport;
  final LatLng? targetLatLng; // << Accept Target Location!!

  TrackingScreen({required this.sport, this.targetLatLng});

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late Timer _timer;
  int _secondsPassed = 0;
  double _travelledDistance = 0.0;
  bool _isTracking = true;

  GoogleMapController? _mapController;
  List<LatLng> _polylineCoordinates = [];
  StreamSubscription<Position>? _positionStream;

  LatLng? _currentLatLng; // For actual current location
  double? _estimatedDistanceToTarget; // << Estimated Distance to Target

  @override
  void initState() {
    super.initState();
    _startTimer();
    _getInitialLocation();
  }

  void _getInitialLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (!serviceEnabled || permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
      _polylineCoordinates.add(_currentLatLng!);

      // Calculate estimated distance to target
      if (widget.targetLatLng != null) {
        _estimatedDistanceToTarget = _calculateDistance(_currentLatLng!, widget.targetLatLng!);
      }
    });

    _startLocationUpdates();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isTracking) {
        setState(() {
          _secondsPassed++;
        });
      }
    });
  }

  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      if (_isTracking) {
        LatLng newPoint = LatLng(position.latitude, position.longitude);
        setState(() {
          if (_polylineCoordinates.isNotEmpty) {
            _travelledDistance += _calculateDistance(_polylineCoordinates.last, newPoint);
          }
          _polylineCoordinates.add(newPoint);

          // Update estimated distance to target
          if (widget.targetLatLng != null) {
            _estimatedDistanceToTarget = _calculateDistance(newPoint, widget.targetLatLng!);
          }
        });

        _mapController?.animateCamera(CameraUpdate.newLatLng(newPoint));
      }
    });
  }

  double _calculateDistance(LatLng start, LatLng end) {
    final distanceInMeters = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
    return distanceInMeters / 1000; // meters to km
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _pauseOrResume() {
    setState(() {
      _isTracking = !_isTracking;
    });
  }

  void _resetTracking() {
    setState(() {
      _secondsPassed = 0;
      _travelledDistance = 0.0;
      _polylineCoordinates.clear();
      _isTracking = false;
    });
  }

  void _finishTracking() {
    _timer.cancel();
    _positionStream?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          distance: _travelledDistance,
          durationSeconds: _secondsPassed,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLatLng == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sport),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLatLng!,
              zoom: 16,
            ),
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            polylines: {
              Polyline(
                polylineId: PolylineId("tracking_route"),
                points: _polylineCoordinates,
                color: Colors.orange,
                width: 5,
              ),
              if (widget.targetLatLng != null)
                Polyline(
                  polylineId: PolylineId("target_route"),
                  points: [_currentLatLng!, widget.targetLatLng!],
                  color: Colors.blueAccent,
                  width: 3,
                  patterns: [PatternItem.dash(20), PatternItem.gap(10)],
                ),
            },
            markers: {
              if (widget.targetLatLng != null)
                Marker(
                  markerId: MarkerId("target"),
                  position: widget.targetLatLng!,
                  infoWindow: InfoWindow(title: "Target Location"),
                ),
            },
          ),
          // Distance & Duration
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Travelled: ${_travelledDistance.toStringAsFixed(2)} km",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (_estimatedDistanceToTarget != null)
                    Text(
                      "Est. to Target: ${_estimatedDistanceToTarget!.toStringAsFixed(2)} km",
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  Text(
                    _formatDuration(_secondsPassed),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          // Buttons
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.orange[900],
                  heroTag: "pause",
                  onPressed: _pauseOrResume,
                  child: Icon(
                    _isTracking ? Icons.pause : Icons.play_arrow,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                FloatingActionButton(
                  backgroundColor: Colors.red,
                  heroTag: "reset",
                  onPressed: _resetTracking,
                  child: Icon(Icons.replay, size: 28, color: Colors.white),
                ),
                FloatingActionButton(
                  backgroundColor: Colors.green[700],
                  heroTag: "done",
                  onPressed: _finishTracking,
                  child: Icon(Icons.check, size: 28, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
