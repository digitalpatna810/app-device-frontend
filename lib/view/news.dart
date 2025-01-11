import 'package:flutter/material.dart';

class NewsModule extends StatelessWidget {
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
                  'News Module',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                backgroundColor: Colors.transparent, // Make AppBar transparent
                elevation: 0, // Remove shadow
              ),
            ),
            // Add your news content here
            Expanded(
              child: Center(
                child: Text(
                  'News Content Goes Here',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}