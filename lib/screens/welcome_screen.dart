import 'package:flutter/material.dart';
import 'package:lost_and_found_fnlyrprj/auth_screens/login_screen.dart';
import 'package:lost_and_found_fnlyrprj/auth_screens/registration_screen.dart';
import 'package:lost_and_found_fnlyrprj/screens/user_home.dart';
import 'package:lottie/lottie.dart';

class WelcomeScreen extends StatelessWidget {
  static String id = 'welcome_screen';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF5EDF7),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 35),
            Text(
              'Welcome to',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text('Nile Lost & Found.'),
            SizedBox(height: 40),
            Flexible(child: Lottie.asset('lottie/lostandfoundanimation.json')),
            SizedBox(
              width: 250,
              child: TextButton(
                onPressed: () {
                  // TODO: Add your logic here
                  Navigator.pushNamed(context, RegistrationScreen.id);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Color(0xFFBB99CD),
                  padding: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Register', style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 250,
              child: TextButton(
                onPressed: () {
                  // TODO: Add your logic here
                  Navigator.pushNamed(context, LoginScreen.id);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  // Match background to screen
                  side: BorderSide(color: Color(0xFFBB99CD), width: 2),
                  padding: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Login', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
