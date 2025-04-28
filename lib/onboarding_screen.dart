import 'package:flutter/material.dart';
import 'login.dart'; // Import the login screen

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _controller = PageController();
  int _currentPage = 0;

  List<Map<String, String>> onboardingData = [
    {
      "title": "Track Your Activity",
      "desc": "Monitor your running, cycling, or walking activities easily.",
      "image": "https://scontent.fmnl7-1.fna.fbcdn.net/v/t1.15752-9/494356272_1183603506645387_6398492711150147681_n.png?_nc_cat=108&ccb=1-7&_nc_sid=9f807c&_nc_ohc=Z7CM-TiNiZcQ7kNvwEyfvrh&_nc_oc=AdnnYndnXNRphATccuvr1msHB6FlPPbyigyymEbXYHqa9muUtWuoIEZj7O6OVv0ZA8I&_nc_zt=23&_nc_ht=scontent.fmnl7-1.fna&oh=03_Q7cD2AHj0e2s0bVsbgvt2RhGfMSAu9xr4QHUgzlgfcloEGTslw&oe=6836AA52"
    },
    {
      "title": "Real-time GPS Tracking",
      "desc": "View your live location and route on the map.",
      "image": "https://scontent.fmnl7-2.fna.fbcdn.net/v/t1.15752-9/494357182_1193175038625615_1265998487481747991_n.png?_nc_cat=101&ccb=1-7&_nc_sid=9f807c&_nc_ohc=uDLa6My63egQ7kNvwFgLN2m&_nc_oc=Adn7cz82SAkcB9fkiFiWxHXIGmMFjfh2qEDsf81Fd0yyLD3k7Sl0yzRlmX_LwrWi4e4&_nc_zt=23&_nc_ht=scontent.fmnl7-2.fna&oh=03_Q7cD2AEDMwfKmW6JoTR3AG6kBl9rc4dvi4Ug_xRzXG8CINh5Wg&oe=6836BDEF"
    },
    {
      "title": "A community for you",
      "desc": "Challenge yourself and your friends.",
      "image": "https://scontent.fmnl7-2.fna.fbcdn.net/v/t1.15752-9/494356411_562710930186561_5691628014012064513_n.png?_nc_cat=102&ccb=1-7&_nc_sid=9f807c&_nc_ohc=-boxIvLai-cQ7kNvwE7Yjcd&_nc_oc=AdnDfRgxYEJDUvGJCgMb5iS5RY2S3Pf2DANZ29xbCvPcJoAPL6GvIzv4uK3cPyoVu28&_nc_zt=23&_nc_ht=scontent.fmnl7-2.fna&oh=03_Q7cD2AGFIgNYE61ClWG6k-P7_aMhjuhSq7lDHwKA9nqA_3kwsA&oe=6836C645"
    },
  ];

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _next() {
    if (_currentPage == onboardingData.length - 1) {
      _skip();
    } else {
      _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.network(
            onboardingData[_currentPage]["image"]!,
            fit: BoxFit.cover,
          ),
          // Black overlay (30% opacity)
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          // Foreground content
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _skip,
                    child: Text("Skip", style: TextStyle(color: Colors.white)),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: onboardingData.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Spacer(flex: 3),
                          Text(
                            onboardingData[index]["title"]!,
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          Text(
                            onboardingData[index]["desc"]!,
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          Spacer(flex: 2),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                        (index) => Container(
                      margin: EdgeInsets.all(4),
                      width: _currentPage == index ? 12 : 8,
                      height: _currentPage == index ? 12 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? Colors.white : Colors.white54,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _next,
                    child: Text(
                      _currentPage == onboardingData.length - 1 ? "Get Started" : "Next",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
