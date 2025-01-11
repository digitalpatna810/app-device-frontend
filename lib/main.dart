import 'package:device_management/controller/submission_controller.dart';
import 'package:device_management/services/shared_preference_service.dart';
import 'package:device_management/view/login.dart';
import 'package:device_management/view/onboarding.dart';
import 'package:device_management/view/splash.dart';
 import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'controller/content_controller.dart';
import 'controller/navigation_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp();

  // Setup Firebase App Check
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider("recaptcha-v3-site-key"),
    androidProvider: AndroidProvider.playIntegrity,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContentProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => SubmissionProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EduHub',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          useMaterial3: true, // Enable Material 3
          // Custom color scheme
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFF1565C0),
            brightness: Brightness.light,
          ),
          // Custom text theme
          textTheme: TextTheme(
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          // Custom app bar theme
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1565C0),
          ),
          // Custom elevated button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
               ),
            ),
          ),
        ),
        home: FutureBuilder<bool>(
          future: _initializeApp(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SplashScreen();
            }
            if (snapshot.hasError) {
              return _buildErrorScreen(snapshot.error.toString());
            }
            // Return the appropriate screen based on first-time status
            return snapshot.data == true ? OnboardingScreen() : LoginPage();
          },
        ),
      ),
    );
  }

  Future<bool> _initializeApp() async {
    try {
      // Add any additional initialization logic here
      await Future.delayed(Duration(seconds: 3)); // Minimum splash screen duration
      return await SharedPreferencesService.isFirstTime();
    } catch (e) {
      print('Initialization error: $e');
      rethrow;
    }
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Please try again later',
              style: TextStyle(color: Colors.grey),
            ),
            if (error.isNotEmpty) ...[
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}