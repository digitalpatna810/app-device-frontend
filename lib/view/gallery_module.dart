import 'package:flutter/material.dart';

class GalleryModule extends StatelessWidget {
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
                  'Gallery Module',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                backgroundColor: Colors.transparent, // Make AppBar transparent
                elevation: 0, // Remove shadow
              ),
            ),
            // GridView for gallery images
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.shade700,
                            Colors.purple.shade500,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          'Image ${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: 10, // Example: 10 images
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}