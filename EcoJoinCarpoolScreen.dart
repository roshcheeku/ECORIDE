import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EcoJoinCarpoolScreen extends StatefulWidget {
  @override
  _EcoJoinCarpoolScreenState createState() => _EcoJoinCarpoolScreenState();
}

class _EcoJoinCarpoolScreenState extends State<EcoJoinCarpoolScreen> {
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _passengerNameController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _arrivalTimeController = TextEditingController();

  Future<void> _joinCarpool() async {
    final driverName = _driverNameController.text;
    final passengerName = _passengerNameController.text;
    final startRoute = _startController.text;
    final endRoute = _endController.text;
    final arrivalTime = _arrivalTimeController.text;

    final url = Uri.parse('http://your-server-ip:5000/join_carpool');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'driver_name': driverName,
          'passenger_name': passengerName,
          'source': startRoute,
          'destination': endRoute,
          'arrival_time': arrivalTime,
        }),
      );
      if (response.statusCode == 200) {
        final backendResponse = json.decode(response.body);
        _showDialog('Backend Response', backendResponse['message']);
      } else {
        _showDialog('Error', 'Failed to join carpool');
      }
    } catch (error) {
      _showDialog('Error', 'Something went wrong: $error');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Carpool'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _driverNameController,
                decoration: InputDecoration(
                  labelText: 'Driver Name',
                  labelStyle: TextStyle(color: Colors.pinkAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passengerNameController,
                decoration: InputDecoration(
                  labelText: 'Passenger Name',
                  labelStyle: TextStyle(color: Colors.pinkAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _startController,
                decoration: InputDecoration(
                  labelText: 'Start Route',
                  labelStyle: TextStyle(color: Colors.pinkAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _endController,
                decoration: InputDecoration(
                  labelText: 'End Route',
                  labelStyle: TextStyle(color: Colors.pinkAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _arrivalTimeController,
                decoration: InputDecoration(
                  labelText: 'Arrival Time (YYYY-MM-DD HH:MM) ⏰',
                  labelStyle: TextStyle(color: Colors.pinkAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _joinCarpool,
                child: Text('Join Carpool 🚗'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
