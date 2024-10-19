import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Main DashboardScreen with Bottom Navigation
class DashboardScreen extends StatefulWidget {
  final String role; // Add this line

  DashboardScreen({Key? key, required this.role}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // List of screens for each tab
  final List<Widget> _children = [
    DashboardContent(),
    ProfileScreen(),
    SettingsScreen(),
    EcoRideScreen(), // EcoRideScreen integrated into the tab
  ];

  // Handle tab selection
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: Text('Ecoride 🚗', style: TextStyle(fontFamily: 'Raleway')),
              backgroundColor: Colors.greenAccent.shade100,
              actions: [
                // Optionally display role in the app bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Role: ${widget.role}', // Displaying user role
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          // Display different content based on the role
          if (widget.role == 'driver') ...[
            Text('Welcome, Driver! You can start or manage carpools here.',
                style: TextStyle(fontSize: 18)),
          ] else if (widget.role == 'passenger') ...[
            Text('Welcome, Passenger! Find a carpool that suits you.',
                style: TextStyle(fontSize: 18)),
          ] else ...[
            Text('Welcome! Please select an option from the menu.',
                style: TextStyle(fontSize: 18)),
          ],
          Expanded(child: _children[_currentIndex]), // Display the corresponding screen
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // Call the function when a tab is selected
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental),
            label: 'Carpool',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add quick action logic here
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.greenAccent.shade100,
      ),
    );
  }
}

// DashboardContent with Map and Statistics
class DashboardContent extends StatefulWidget {
  @override
  _DashboardContentState createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final MapController _mapController = MapController();
  double _zoomLevel = 13.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.yellow.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Interactive Map
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: LatLng(12.9716, 77.5946), // Bengaluru coordinates
                  zoom: _zoomLevel,
                  onTap: (tapPosition, point) {
                    // Add interaction logic
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(12.9716, 77.5946),
                        builder: (ctx) => GestureDetector(
                          onTap: () {
                            // Add marker interaction logic
                          },
                          child: Icon(Icons.person_pin_circle, color: Colors.red, size: 40),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Zoom controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.zoom_out),
                  onPressed: () {
                    setState(() {
                      _zoomLevel = (_zoomLevel - 1).clamp(1.0, 18.0);
                      _mapController.move(_mapController.center, _zoomLevel);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.zoom_in),
                  onPressed: () {
                    setState(() {
                      _zoomLevel = (_zoomLevel + 1).clamp(1.0, 18.0);
                      _mapController.move(_mapController.center, _zoomLevel);
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            // Daily Commute Stats and Rewards & Leaderboard side by side
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink.shade100, Colors.pinkAccent.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Commute Stats',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Raleway'),
                        ),
                        SizedBox(height: 10),
                        Text('CO2 saved: 0 kg', style: TextStyle(fontSize: 16)),
                        Text('Money saved: ₹0', style: TextStyle(fontSize: 16)),
                        Text('Distance traveled: 0 km', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade100, Colors.orangeAccent.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rewards and Leaderboard',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Raleway'),
                        ),
                        SizedBox(height: 10),
                        Text('Points earned: 0', style: TextStyle(fontSize: 16)),
                        Text('Top carpoolers: No data', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// EcoRideScreen for Carpooling
class EcoRideScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EcoRide', style: TextStyle(fontFamily: 'Raleway')),
        backgroundColor: Colors.greenAccent.shade100,
      ),
      body: Center(
        child: Text('EcoRide Screen - Carpooling options will be here', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

// ProfileScreen Widget with Enhanced Features
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String profilePicture = 'assets/default_profile.png'; // Default profile image
  String name = 'User Name';
  String email = 'user@example.com';
  String phone = 'Phone Number';
  String address = 'User Address';

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profilePicture = pickedFile.path; // Update profile picture
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontFamily: 'Raleway')),
        backgroundColor: Colors.greenAccent.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage, // Handle image selection
              child: CircleAvatar(
                radius: 50,
                backgroundImage: FileImage(File(profilePicture)),
                child: Icon(Icons.camera_alt, size: 30), // Placeholder icon for image
              ),
            ),
            SizedBox(height: 16),
            Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(email, style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(phone, style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(address, style: TextStyle(fontSize: 16)),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Log out logic
              },
            child: Text('Log Out'),
style: ElevatedButton.styleFrom(
  backgroundColor: Colors.redAccent, // Use backgroundColor instead of primary
),
            )

          ],
        ),
      ),
    );
  }
}

// SettingsScreen Widget with Enhanced Features
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontFamily: 'Raleway')),
        backgroundColor: Colors.greenAccent.shade100,
      ),
      body: Center(
        child: Text('Settings Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
