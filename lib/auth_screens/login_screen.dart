import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found_fnlyrprj/auth_screens/registration_screen.dart';
import 'package:lost_and_found_fnlyrprj/screens/welcome_screen.dart';

import '../screens/user_home.dart';
import 'package:lost_and_found_fnlyrprj/screens/admin_panel_screen.dart'; // Import admin home screen

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  bool _isLoading = false;

  void _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isLoading = true);

      try {
        // Sign in user with email and password
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email!,
          password: _password!,
        );

        // Get the current user and fetch their role from Firestore
        User? user = FirebaseAuth.instance.currentUser;
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .get();

        String role = userDoc['role']; // Retrieve the user's role

        // Redirect based on user role
        if (role == 'admin') {
          Navigator.pushReplacementNamed(
            context,
            AdminPanelScreen.id,
          ); // Navigate to Admin Home
        } else if (role == 'user') {
          Navigator.pushReplacementNamed(
            context,
            UserHome.id,
          ); // Navigate to User Home
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Invalid role, contact support.")),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Login failed. Please try again.';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password.';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Color(0xFF3D1860)),
                      onPressed:
                          () => Navigator.pushNamed(context, WelcomeScreen.id),
                    ),
                  ),
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D1860),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) => _email = value,
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Please enter your email' : null,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    onSaved: (value) => _password = value,
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Please enter your password'
                                : null,
                  ),
                  SizedBox(height: 30),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                        onPressed: _submitLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFBB99CD),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFF3D1860),
                            fontSize: 18,
                          ),
                        ),
                      ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // Navigate to RegistrationScreen
                      Navigator.pushNamed(context, RegistrationScreen.id);
                    },
                    child: Text(
                      "Don't have an account? Register here",
                      style: TextStyle(color: Color(0xFF3D1860)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
