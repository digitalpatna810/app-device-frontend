import 'package:device_management/view/profile_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'create_content_page.dart';
import 'login.dart';
import 'submission_page.dart';

class UserDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background for the entire screen
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade700,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient AppBar
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade800,
                    Colors.purple.shade600,
                  ],
                ),
              ),
              child: AppBar(
                centerTitle: true,
                title: Text(
                  'User Dashboard',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                backgroundColor: Colors.transparent, // Make AppBar transparent
                elevation: 0, // Remove shadow
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildDashboardCard(
                      context,
                      icon: Icons.edit,
                      title: 'Create Content',
                      colors: [Colors.teal.shade700, Colors.teal.shade400],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CreateContentPage()),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Icons.assignment_turned_in,
                      title: 'My Submissions',
                      colors: [Colors.blueAccent.shade700, Colors.blueAccent.shade400],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SubmissionsPage()),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Icons.person,
                      title: 'Profile Settings',
                      colors: [Colors.deepPurpleAccent.shade700, Colors.deepPurpleAccent.shade400],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProfileSettingsPage()),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Icons.logout,
                      title: 'Logout',
                      colors: [Colors.orangeAccent.shade700, Colors.orangeAccent.shade400],
                      onTap: () => logout(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required List<Color> colors,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      print('User logged out successfully');

      // Navigate to the login screen (replace the current screen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}