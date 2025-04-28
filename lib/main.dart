import 'package:flutter/material.dart';
import 'splash_screen.dart'; // <-- Import SplashScreen
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'start_tracking_screen.dart';
import 'tracking_summary_screen.dart';
import 'profile.dart';
import 'challenge.dart';
import 'feed.dart';
import 'swimming_timer_screen.dart';


void main() {
  runApp(KardjoApp());
}

class KardjoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Start from splash
      routes: {
        '/': (context) => SplashScreen(), // Splash first
        '/onboarding': (context) => OnboardingScreen(),
        '/home': (context) => HomeScreen(),
        '/start_tracking': (context) => StartTrackingScreen(),
        '/challenge': (context) => ChallengeHomePage(),
        '/tracking_summary': (context) => TrackingSummaryScreen(),
        '/feed': (context) => FeedPage(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
