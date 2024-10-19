import 'package:flutter/material.dart';
import 'login.dart';
import 'dart:async'; // for the Timer

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Adjusting the duration to 4.5 seconds and stopping at the 3rd page
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_currentPage < 2) {
        setState(() {
          _currentPage++;
        });
      } else {
        _timer.cancel(); // Stop the timer once it reaches the 3rd page
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> _buildPages() {
    return [
      _buildPage(
        imagePath: 'assets/carpool.jpg',
        title: 'Welcome to ECOride!',
        description: 'Create a virtual carpooling network for employees.',
      ),
      _buildPage(
        imagePath: 'assets/carpool2.jpg',
        title: 'Match Commuting Routes',
        description: 'Our system matches employees with similar routes.',
      ),
      _buildPage(
        imagePath: 'assets/carpool3.jpg',
        title: 'Incentives',
        description: 'Get preferential parking and toll discounts.',
      ),
    ];
  }

  Widget _buildPage({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ScaleTransition(
            scale: _animation,
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ),
        SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(fontSize: 24, fontFamily: 'Raleway', fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            description,
            style: TextStyle(fontSize: 16, fontFamily: 'Raleway'),
            textAlign: TextAlign.center,
          ),
        ),
        if (title == 'Incentives') ...[
          SizedBox(height: 20),
          SizedBox(
            width: 150,
            height: 30,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent.shade100,
              ),
              child: Text(
                'Login / Sign Up',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              // Skip action
            },
            child: Text(
              'Skip for now',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
                _animationController.reset();
                _animationController.forward();
              });
            },
            children: _buildPages(),
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _buildPages().length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  width: _currentPage == index ? 12.0 : 8.0,
                  height: _currentPage == index ? 12.0 : 8.0,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.blue : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
