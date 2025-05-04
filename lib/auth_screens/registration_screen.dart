import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lost_and_found_fnlyrprj/screens/user_home.dart';

import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name, _email, _password;
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // SAVE the form values here first
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email!,
          password: _password!,
        );

        User? user = FirebaseAuth.instance.currentUser;
        await user?.updateDisplayName(_name);

        // Add user details to Firestore and set role as 'user'
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).set(
          {
            'name': _name,
            'email': _email,
            'role': 'user', // Default role for new users
          },
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration Successful!')));

        // Navigate to User Home
        Navigator.pushReplacementNamed(context, UserHome.id);
      } catch (e) {
        String errorMessage = 'Registration Failed. Please try again.';
        if (e is FirebaseAuthException) {
          if (e.code == 'email-already-in-use') {
            errorMessage = 'This email is already registered.';
          } else if (e.code == 'weak-password') {
            errorMessage = 'Password should be at least 6 characters.';
          }
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Color(0xFFBB99CD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (val) => _name = val,
                validator:
                    (val) => val!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (val) => _email = val,
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Please provide an email address';
                  } else if (!RegExp(
                    r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                  ).hasMatch(val)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (val) => _password = val,
                validator:
                    (val) => val!.isEmpty ? 'Please enter a password' : null,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                      backgroundColor: Color(0xFFBB99CD),
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(color: Color(0xFF3D1860)),
                    ),
                  ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already registered?'),
                  TextButton(
                    onPressed: () {
                      // Navigate to login screen
                      Navigator.pushReplacementNamed(context, LoginScreen.id);
                    },
                    child: Text(
                      'Login here',
                      style: TextStyle(color: Color(0xFFBB99CD)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
