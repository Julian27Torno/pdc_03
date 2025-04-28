import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'tracking_screen.dart';
import 'swimming_timer_screen.dart';
import 'home_screen.dart'; // <<--- ADD THIS if not yet

class StartTrackingScreen extends StatefulWidget {
  static String? lastSelectedSport;
  LatLng? _selectedTarget;

  @override
  _StartTrackingScreenState createState() => _StartTrackingScreenState();
}

class _StartTrackingScreenState extends State<StartTrackingScreen> {
  String _selectedSport = "Running";
  final List<String> _sports = ["Running", "Cycling", "Swimming"];

  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  LatLng? _targetLatLng;

  double _selectedSpeedMultiplier = 1.0; // Default normal

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (!serviceEnabled || permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng tappedPoint) {
    setState(() {
      _targetLatLng = tappedPoint;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLatLng == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Start Tracking"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Stack(
        children: [
          // Google Map
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLatLng!,
                zoom: 16,
              ),
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              onTap: _onMapTap,
              markers: {
                Marker(
                  markerId: const MarkerId("current"),
                  position: _currentLatLng!,
                  infoWindow: const InfoWindow(title: "You are here"),
                ),
                if (_targetLatLng != null)
                  Marker(
                    markerId: const MarkerId("target"),
                    position: _targetLatLng!,
                    infoWindow: const InfoWindow(title: "Target Location"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                  ),
              },
            ),
          ),

          // Sport and Speed Dropdown
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                _buildDropdownSport(),
                const SizedBox(height: 10),
                if (_selectedSport == "Swimming") _buildDropdownSpeed(),
              ],
            ),
          ),

          // Start Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(160, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _startTracking,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.play_arrow, size: 30, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Start", style: TextStyle(fontSize: 20, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSport() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSport,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          isExpanded: true,
          items: _sports.map((sport) {
            return DropdownMenuItem<String>(
              value: sport,
              child: Row(
                children: [
                  Icon(
                    sport == "Running"
                        ? Icons.directions_run
                        : sport == "Cycling"
                        ? Icons.directions_bike
                        : Icons.pool,
                    size: 20,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(sport, style: const TextStyle(color: Colors.black)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSport = value!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDropdownSpeed() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Speed: ", style: TextStyle(fontSize: 16)),
          DropdownButton<double>(
            value: _selectedSpeedMultiplier,
            items: const [
              DropdownMenuItem(value: 0.5, child: Text("Slow")),
              DropdownMenuItem(value: 1.0, child: Text("Normal")),
              DropdownMenuItem(value: 2.0, child: Text("Fast")),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedSpeedMultiplier = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _startTracking() async {
    StartTrackingScreen.lastSelectedSport = _selectedSport;

    if (_selectedSport == "Swimming") {
      double? customLapMeters = await showDialog<double>(
        context: context,
        builder: (context) {
          TextEditingController lapController = TextEditingController();
          return AlertDialog(
            title: const Text('Set Lap Distance'),
            content: TextField(
              controller: lapController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Enter meters per lap (e.g. 50)"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  double enteredValue = double.tryParse(lapController.text) ?? 0.0;
                  if (enteredValue > 0) {
                    Navigator.pop(context, enteredValue);
                  }
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (customLapMeters != null && customLapMeters > 0) {
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => SwimmingTimerScreen(
              metersPerLap: customLapMeters,
              speedMultiplier: _selectedSpeedMultiplier,
            ),
          ),
        );

        if (result != null) {
          double distanceKm = (result['distanceInMeters'] as double) / 1000.0;
          int durationSeconds = result['durationSeconds'];

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                distance: distanceKm,
                durationSeconds: durationSeconds,
              ),
            ),
          );
        }
      }
    } else {
      if (_targetLatLng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a target location first!')),
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrackingScreen(
            sport: _selectedSport,
            targetLatLng: _targetLatLng,
          ),
        ),
      );
    }
  }
}
