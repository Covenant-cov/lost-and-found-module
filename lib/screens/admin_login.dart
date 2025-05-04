import 'package:flutter/material.dart';
import 'admin_panel_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  static String id = 'admin_login';

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _passwordController = TextEditingController();
  final _adminPassword = 'verysecretpw'; // Change this to your secret

  void _validatePassword() {
    if (_passwordController.text == _adminPassword) {
      Navigator.pushNamed(context, AdminPanelScreen.id);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Incorrect password')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Login'),
        backgroundColor: Color(0xFFBB99CD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Enter Admin Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validatePassword,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                textStyle: TextStyle(fontSize: 16),
                backgroundColor: Color(0xFFBB99CD),
              ),
              child: Text(
                'Access Admin Panel',
                style: TextStyle(color: Color(0xFF3D1860)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
