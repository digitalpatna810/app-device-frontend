import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/searchbar_widget.dart';
import 'userdashboard.dart';
import 'gallery_module.dart';
import '../widgets/navgigationbar.dart';
import '../controller/navigation_controller.dart';
import 'news.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _categories = [
    'Medical',
    'Engineering',
    'News',
    'Gallery'
  ];
  final List<Widget> _screens = [
    Center(child: Text('Welcome to Home', style: TextStyle(fontSize: 24, color: Colors.white))),
    NewsModule(),
    GalleryModule(),
    UserDashboard(),
  ];

  List<String> _selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    // Filter content based on selected categories
    List<Widget> filteredScreens = _screens.where((screen) {
      if (_selectedCategories.isEmpty) return true; // Show all if no filter
      if (_selectedCategories.contains('News') && screen is NewsModule) {
        return true;
      }
      if (_selectedCategories.contains('Gallery') && screen is GalleryModule) {
        return true;
      }
      return false;
    }).toList();

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
                leading: null,
                centerTitle: true,
                title: Text(
                  'HomePage',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                backgroundColor: Colors.transparent, // Make AppBar transparent
                elevation: 0, // Remove shadow
              ),
            ),
            // Gradient SearchBarWidget
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade700,
                      Colors.purple.shade500,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SearchBarWidget(
                    categories: _categories,
                    onCategorySelected: (selectedCategories) {
                      setState(() {
                        _selectedCategories = selectedCategories;
                      });
                    },
                  ),
                ),
              ),
            ),
            // Display the selected category if any category is selected
            if (_selectedCategories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Selected Categories: ${_selectedCategories.join(', ')}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
              ),
            // Display the selected screen from the filtered screens
            Expanded(
              child: filteredScreens.isNotEmpty
                  ? AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: filteredScreens[navigationProvider.currentIndex],
              )
                  : Center(
                child: Text(
                  'No content available for selected categories.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: CustomBottomNavigationBar(), // Custom navigation bar
    );
  }
}