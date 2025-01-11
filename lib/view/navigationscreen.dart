import 'package:device_management/view/userdashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/navigation_controller.dart';
import '../widgets/navgigationbar.dart';
import 'gallery_module.dart';
import 'home.dart';
import 'news.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NavigationProvider>(context);
    return Scaffold(
      extendBody: true, // Ensures the navigation bar overlaps the content.
      body: IndexedStack(
        index: provider.currentIndex,
        children:   [
          HomeScreen(),
          NewsModule(),
          GalleryModule(),
          UserDashboard(),
        ],
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}
