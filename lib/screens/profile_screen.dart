import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lost_and_found_fnlyrprj/auth_screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  static String id = 'profile_screen';

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF643579),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF643579),
              child: Text(
                user?.displayName?.isNotEmpty == true
                    ? user!.displayName![0].toUpperCase()
                    : 'U',
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            SizedBox(height: 12),
            Text(
              user?.displayName ?? 'User',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(user?.email ?? '', style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 30),

            // Profile Info Cards
            _buildInfoCard(
              Icons.email,
              "Email",
              user?.email ?? "Not available",
            ),
            _buildInfoCard(Icons.badge, "User ID", user?.uid ?? "Unavailable"),

            SizedBox(height: 20),

            // Logout button
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    LoginScreen.id,
                    // Change this to your actual login route name
                    (route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error signing out. Please try again.'),
                    ),
                  );
                }
              },
              icon: Icon(Icons.logout),
              label: Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF643579)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value),
      ),
    );
  }
}
