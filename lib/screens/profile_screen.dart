import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lost_and_found_fnlyrprj/auth_screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  static String id = 'profile_screen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _refreshUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: user?.displayName ?? '');
    final newPasswordController = TextEditingController();
    final currentPasswordController = TextEditingController();
    bool isPasswordVisible = false; // Track visibility of password

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Display Name'),
                ),
                TextField(
                  controller: currentPasswordController,
                  obscureText: !isPasswordVisible, // Toggle visibility
                  decoration: InputDecoration(
                    labelText: 'Current Password (for password change)',
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Color(0xFF643579),
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible; // Toggle password visibility
                        });
                      },
                    ),
                  ),
                ),
                TextField(
                  controller: newPasswordController,
                  obscureText: !isPasswordVisible, // Toggle visibility
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Color(0xFF643579),
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible; // Toggle password visibility
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Save', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                try {
                  // Update display name if changed
                  if (nameController.text.trim().isNotEmpty) {
                    await user?.updateDisplayName(nameController.text.trim());
                  }

                  // Update password if provided
                  if (newPasswordController.text.trim().isNotEmpty) {
                    if (currentPasswordController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter your current password.')),
                      );
                      return;
                    }

                    // Ask confirmation before proceeding
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Confirm Password Change"),
                        content: Text(
                          "Are you sure you want to change your password? You may need to re-login on other devices.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text("Confirm"),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    // Re-authenticate user
                    final cred = EmailAuthProvider.credential(
                      email: user!.email!,
                      password: currentPasswordController.text.trim(),
                    );

                    await user!.reauthenticateWithCredential(cred);

                    // Now update the password
                    await user!.updatePassword(newPasswordController.text.trim());
                  }

                  await _refreshUser();
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile updated successfully')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Update failed: ${e.toString()}')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }


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

            // Edit button
            TextButton.icon(
              onPressed: () => _showEditProfileDialog(context),
              icon: Icon(Icons.edit, color: Color(0xFF643579)),
              label: Text("Edit Profile", style: TextStyle(color: Color(0xFF643579))),
            ),
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
