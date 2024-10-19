import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EcoCarpoolScreen extends StatefulWidget {
  @override
  _EcoCarpoolScreenState createState() => _EcoCarpoolScreenState();
}

class _EcoCarpoolScreenState extends State<EcoCarpoolScreen> {
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _arrivalTimeController = TextEditingController();
  final int _maxPassengers = 3; // Set as per your requirement

  Future<void> _initiateCarpool() async {
    final driverName = _driverNameController.text;
    final startRoute = _startController.text;
    final endRoute = _endController.text;
    final arrivalTime = _arrivalTimeController.text;
    final url = Uri.parse('http://127.0.0.1:5000/initiate_carpool');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'driver_name': driverName,
          'source': startRoute,
          'destination': endRoute,
          'arrival_time': arrivalTime,
          'max_passengers': _maxPassengers,
        }),
      );
      if (response.statusCode == 200) {
        final backendResponse = json.decode(response.body);
        _showDialog('Backend Response', backendResponse['message']);
      } else {
        _showDialog('Error', 'Failed to create carpool');
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
        title: Text('Create Carpool'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _driverNameController,
                decoration: InputDecoration(
                  labelText: 'Driver Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _startController,
                decoration: InputDecoration(
                  labelText: 'Start Route',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _endController,
                decoration: InputDecoration(
                  labelText: 'End Route',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _arrivalTimeController,
                decoration: InputDecoration(
                  labelText: 'Arrival Time (YYYY-MM-DD HH:MM)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initiateCarpool,
                child: Text('Create Carpool 🚗'),
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
