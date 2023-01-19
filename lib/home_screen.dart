import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? paymentIntent;
  Map<String, dynamic>? customerData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                await makePayment();
              },
              child: const Text('Make Payment'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      customerData = await createCustomer();
      paymentIntent =
          await createPaymentIntent('100', 'INR', customerData!['id']);

      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!['client_secret'],
            style: ThemeMode.dark,
            merchantDisplayName: 'Chirag',
          ))
          .then((value) => {});

      displayPaymentSheet();
    } catch (err) {
      throw Exception(err);
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 100,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text('Payment Successfull')
              ],
            ),
          ),
        );

        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text('Payment failed')
              ],
            )
          ],
        ),
      );
    } catch (e) {
      print('$e');
    }
  }

  createCustomer() async {
    try {
      Map<String, dynamic> bodyParams = {
        'name': 'Your Name',
        'address[line1]': 'amrut',
        'address[postal_code]': '123456',
        'address[city]': 'City',
        'address[state]': 'State',
        'address[country]': 'in',
      };

      var response =
          await http.post(Uri.parse('https://api.stripe.com/v1/customers'),
              headers: {
                'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
                'Content-Type': 'application/x-www-form-urlencoded',
              },
              body: bodyParams);

      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  createPaymentIntent(String amount, String currency, String customerId) async {
    try {
      Map<String, dynamic> bodyParams = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'description': 'Service provided for software',
        'customer': customerId,
      };

      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          headers: {
            'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: bodyParams);

      return json.decode(response.body);
    } catch (err) {
      print(err);
      throw Exception(err.toString());
    }
  }

  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount) * 100);
    return calculatedAmount.toString();
  }
}
