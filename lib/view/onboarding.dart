import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../services/shared_preference_service.dart';
import 'login.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  bool isLastPage = false;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Welcome to EduHub',
      description: 'Your one-stop platform for educational content sharing and collaboration',
      lottieAsset: 'assets/animations/welcome.json',
      backgroundColor: Color(0xFFE3F2FD),
      textColor: Color(0xFF1565C0),
    ),
    OnboardingPage(
      title: 'Rich Content Library',
      description: 'Access a vast collection of medical and engineering articles, news updates, and multimedia resources',
      lottieAsset: 'assets/animations/library.json',
      backgroundColor: Color(0xFFE8F5E9),
      textColor: Color(0xFF2E7D32),
    ),
    OnboardingPage(
      title: 'Create & Share',
      description: 'Submit your own articles, share knowledge, and contribute to the community',
      lottieAsset: 'assets/animations/create.json',
      backgroundColor: Color(0xFFEDE7F6),
      textColor: Color(0xFF4527A0),
    ),
    OnboardingPage(
      title: 'Stay Updated',
      description: 'Get the latest news, updates, and trending content in your field',
      lottieAsset: 'assets/animations/news.json',
      backgroundColor: Color(0xFFFCE4EC),
      textColor: Color(0xFFC2185B),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: controller,
            onPageChanged: (index) {
              setState(() => isLastPage = index == pages.length - 1);
            },
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return buildOnboardingPage(pages[index]);
            },
          ),
          Container(
            alignment: Alignment.topRight,
            padding: EdgeInsets.only(top: 50, right: 20),
            child: TextButton(
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 16,
                  color: pages[controller.hasClients ? controller.page?.round() ?? 0 : 0].textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => goToLogin(context),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: pages[controller.hasClients ? controller.page?.round() ?? 0 : 0].backgroundColor,
        padding: EdgeInsets.symmetric(horizontal: 20),
        height: 180,
        child: Column(
          children: [
            Center(
              child: SmoothPageIndicator(
                controller: controller,
                count: pages.length,
                effect: WormEffect(
                  spacing: 16,
                  dotColor: Colors.black26,
                  activeDotColor: pages[controller.hasClients ? controller.page?.round() ?? 0 : 0].textColor,
                  dotHeight: 12,
                  dotWidth: 12,
                ),
                onDotClicked: (index) => controller.animateToPage(
                  index,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                ),
              ),
            ),
            SizedBox(height: 32),
            isLastPage
                ? ElevatedButton(
              onPressed: () => goToLogin(context),
              child: Text(
                'Get Started',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: pages.last.textColor,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 56),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
                : ElevatedButton(
              onPressed: () => controller.nextPage(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
              child: Text(
                'Next',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: pages[controller.hasClients ? controller.page?.round() ?? 0 : 0].textColor,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 56),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget buildOnboardingPage(OnboardingPage page) {
    return Container(
      color: page.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            page.lottieAsset,
            height: 300,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 64),
          Text(
            page.title,
            style: TextStyle(
              color: page.textColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: page.textColor.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void goToLogin(BuildContext context) async {
    await SharedPreferencesService.setFirstTime(false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String lottieAsset;
  final Color backgroundColor;
  final Color textColor;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.backgroundColor,
    required this.textColor,
  });
}