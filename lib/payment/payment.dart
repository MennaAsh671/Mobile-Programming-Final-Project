import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/payment/paymentmodel.dart';

class PaymentPage extends StatefulWidget {

  const PaymentPage({Key? key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPaymentMethod = '';
  bool _creditCardDetailsSaved = false; // Track whether credit card details are saved

  TextEditingController cardNumberController = TextEditingController();
  TextEditingController expirationDateController = TextEditingController();
  TextEditingController cvvController = TextEditingController();


  Future<void> _fetchCreditCardDetails() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('creditCards')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print("Credit Card details are saved");
        _creditCardDetailsSaved = true; // Set to true if details exist
      }
    } catch (e) {
      print('Error fetching credit card details: $e');
    }
  }

  Future<void> _saveCreditCardDetails() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Save credit card details to Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('creditCards')
          .add({
        'cardNumber': cardNumberController.text,
        'expirationDate': expirationDateController.text,
        'cvv': cvvController.text,
      });

      _showValidSnackBar('Credit card details saved successfully!');
      _creditCardDetailsSaved = true; // Set to true after saving details
    } catch (e) {
      print('Error saving credit card details: $e');
      _showErrorSnackBar('Failed to save credit card details...Please try again.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showValidSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetch credit card details when the page loads
    _fetchCreditCardDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Payment Method'),
        centerTitle: true,
        backgroundColor: Colors.purpleAccent,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.network(
                  "https://cdn-icons-png.flaticon.com/512/6963/6963703.png",
                  height: 90,
                ),
              ),
              const SizedBox(height: 20.0),
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Center(
                  child: Text( "",
                    // 'Pay your Fare : ${widget.fare} EGP',
                    style: TextStyle(fontSize: 20,color: Colors.purpleAccent),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedPaymentMethod = 'Cash';
                  });
                  // _showValidSnackBar('Payment method selected: Cash');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedPaymentMethod == 'Cash'
                      ? Colors.purpleAccent
                      : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: const Text(
                  'Pay with Cash',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedPaymentMethod = 'Credit Card';
                  });
                  // Fetch credit card details only if they are not saved yet
                  if (!_creditCardDetailsSaved) {
                    _fetchCreditCardDetails();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedPaymentMethod == 'Credit Card'
                      ? Colors.purpleAccent
                      : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: const Text(
                  'Pay with Credit Card',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              if (_selectedPaymentMethod == 'Credit Card' && !_creditCardDetailsSaved) ...[
                // Display credit card input fields only if details are not saved yet
                const SizedBox(height: 30.0),
                TextField(
                  controller: cardNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: expirationDateController,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'Expiration Date (MM/YY)',
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: cvvController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                 if (_selectedPaymentMethod.isNotEmpty) {
                   if (_selectedPaymentMethod == 'Credit Card') {
                    // Check if credit card details are already saved
                    if (!_creditCardDetailsSaved) {
                      // Save credit card details only if not already saved
                      _saveCreditCardDetails();
                    } else {
                      // Show a message indicating that details are already saved
                      _showErrorSnackBar('Credit card details already saved!');
                    }
                  } else {
                     _showValidSnackBar('Payment method selected: Cash');
                   }
                  } else {
                    // Handle other payment methods or show an error message
                    _showErrorSnackBar('Please select a payment method.');
                  }
                },
                style: ElevatedButton.styleFrom(
                  // minimumSize: Size.square(10),
                  backgroundColor: Colors.purpleAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: const Text(
                  'Save Payment Method',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


