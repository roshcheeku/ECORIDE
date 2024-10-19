import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPaymentMethod = 'card';
  final TextEditingController _startAddressController = TextEditingController();
  final TextEditingController _endAddressController = TextEditingController();
  double? _calculatedPrice;

  Future<void> calculatePrice() async {
    final String startAddress = _startAddressController.text;
    final String endAddress = _endAddressController.text;

    final response = await http.post(
      Uri.parse('http://your-backend-ip:5000/calculate_price'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'start_address': startAddress,
        'end_address': endAddress,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _calculatedPrice = data['price'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to calculate price')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Payment Page'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Enter Trip Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: _startAddressController,
                decoration: InputDecoration(
                  labelText: 'Start Address',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _endAddressController,
                decoration: InputDecoration(
                  labelText: 'End Address',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: calculatePrice,
                child: Text('Calculate Price'),
              ),
              SizedBox(height: 16),
              if (_calculatedPrice != null)
                Text('Calculated Price: \$${_calculatedPrice!.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_selectedPaymentMethod.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select a payment method')),
                    );
                  } else {
                    _showSuccessDialog(context);
                  }
                },
                child: Text('Pay Now'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Successful'),
        content: Text('Your payment has been processed successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
