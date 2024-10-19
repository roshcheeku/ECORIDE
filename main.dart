import 'package:flutter/material.dart';
import 'screens/onboarding.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/dashboard.dart';
import 'screens/additional_signup.dart';
import 'screens/otp_verification.dart';
import 'package:carpoolingapp/screens/PaymentPage.dart' as payment;
import 'package:carpoolingapp/screens/EcoJoinCarpoolScreen.dart'; // Make sure to import the JoinCarpoolScreen
import 'package:carpoolingapp/screens/EcoCarpoolScreen.dart'; // Make sure to import the JoinCarpoolScreen

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECOride',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: OnboardingScreen(), // This is the initial screen
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/additional_signup': (context) => AdditionalSignupScreen(),
        '/otp_verification': (context) => OtpVerificationScreen(),
        '/dashboard': (context) => DashboardScreen(role: 'userRole'), // Pass 'role' here
        '/payment': (context) => payment.PaymentPage(),
          '/joinCarpool': (context) => EcoJoinCarpoolScreen(), // Ensure this is correct
// Make sure this import path is correct
 // Make sure this import path is correct
        // Add other routes here if necessary
      },
    );
  }
}
