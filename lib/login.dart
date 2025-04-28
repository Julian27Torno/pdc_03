import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import HomeScreen!

class LoginScreen extends StatelessWidget {
  void _showAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.g_mobiledata, size: 30, color: Colors.black),
              SizedBox(width: 8),
              Text('Select your account'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/profile1.jpg'),
                ),
                title: Text('Don Henessy David'),
                subtitle: Text('don@works.com'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/profile2.jpg'),
                ),
                title: Text('Henessy Don'),
                subtitle: Text('henessydon@gmail.com'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.network(
            'https://scontent.fmnl7-2.fna.fbcdn.net/v/t1.15752-9/494356873_680401494592148_2449123744585844025_n.png?_nc_cat=101&ccb=1-7&_nc_sid=9f807c&_nc_ohc=QTBhv9_-J-cQ7kNvwHwCIPt&_nc_oc=Adkdj5MvoEAolLeaOYHM6a3LNfNc_kJSNW2D4WypmZDX5TR2ilDr41OXG8Ya1dfCYks&_nc_zt=23&_nc_ht=scontent.fmnl7-2.fna&oh=03_Q7cD2AGEfAdq0GrCZggl3JLExGZnkXPX37d1iQNy76us-xv2gw&oe=68369C3E', // Replace with your real background URL
            fit: BoxFit.cover,
          ),
          // Black transparent overlay

          SafeArea(
            child: Column(
              children: [
                Spacer(flex: 3),
                // Runner Icon at top

                Spacer(flex: 2),
                // Login Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: Icon(Icons.g_mobiledata, color: Colors.black),
                        label: Text("Login with Google", style: TextStyle(color: Colors.black)),
                        onPressed: () => _showAccountDialog(context),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: Icon(Icons.apple, color: Colors.black),
                        label: Text("Login with AppleID", style: TextStyle(color: Colors.black)),
                        onPressed: () => _showAccountDialog(context),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
