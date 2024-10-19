import 'package:flutter/material.dart';
import 'signup.dart';
import 'dashboard.dart'; // Assume this is a general dashboard, modify as needed for passenger/carpooler.

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login', style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.pinkAccent.shade100,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade50, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          image: DecorationImage(
            image: AssetImage('assets/carpool_bg.png'), // Your illustration background
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.3), BlendMode.dstATop),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 100, color: Colors.pinkAccent.shade100),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Username/Email',
                  labelStyle: TextStyle(fontFamily: 'Raleway'),
                  prefixIcon: Icon(Icons.email, color: Colors.pinkAccent.shade100),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onTap: () => _wiggleIcon(context),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(fontFamily: 'Raleway'),
                  prefixIcon: Icon(Icons.lock, color: Colors.pinkAccent.shade100),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                obscureText: true,
                onTap: () => _wiggleIcon(context),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                  ),
                  Text('Remember Me', style: TextStyle(fontFamily: 'Raleway')),
                ],
              ),
              SizedBox(
                width: 150,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    _showRoleDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Sign In', style: TextStyle(fontSize: 16, fontFamily: 'Raleway')),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                child: Text('Create Account', style: TextStyle(color: Colors.blueAccent, fontFamily: 'Raleway')),
              ),
              TextButton(
                onPressed: () {
                  // Add password recovery logic
                },
                child: Text('Forgot Password?', style: TextStyle(color: Colors.blueAccent, fontFamily: 'Raleway')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _wiggleIcon(BuildContext context) {
    final duration = Duration(milliseconds: 500);
    final curve = Curves.elasticOut;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.1),
      transitionDuration: duration,
      pageBuilder: (_, __, ___) => Container(),
      transitionBuilder: (_, animation, __, child) {
        return Transform.scale(
          scale: animation.value,
          child: child,
        );
      },
    );
  }

  // Function to show a dialog for role selection
  void _showRoleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Your Role'),
          content: Text('Are you logging in as a passenger or a carpooler?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToDashboard(context, 'passenger');
              },
              child: Text('Passenger'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToDashboard(context, 'carpooler');
              },
              child: Text('Carpooler'),
            ),
          ],
        );
      },
    );
  }

  // Function to navigate to the appropriate dashboard
  void _navigateToDashboard(BuildContext context, String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardScreen(role: role)),
    );
  }
}
