import 'package:flutter/material.dart';
import 'env.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
// set the publishable key for Stripe - this is mandatory
  Stripe.publishableKey = stripePublishableKey;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.green),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Stripe Demo'),
        ),
        body: PaymentScreen(),
      ),
    );
  }
}


// payment_screen.dart
class PaymentScreen extends StatelessWidget {

   Future<void> openPaymentSheetWidget() async {
   try {
     paymentIntentData = await callPaymentIntentApi('200', 'INR');
     await Stripe.instance
         .initPaymentSheet(
       paymentSheetParameters: SetupPaymentSheetParameters(
         appearance: PaymentSheetAppearance(
           primaryButton: const PaymentSheetPrimaryButtonAppearance(
             colors: PaymentSheetPrimaryButtonTheme(
               light: PaymentSheetPrimaryButtonThemeColors(
                 background: Colors.blue,
               ),
             ),
           ),
           colors: PaymentSheetAppearanceColors(background: blueShade50),
         ),
         paymentIntentClientSecret: paymentIntentData!['client_secret'],
         style: ThemeMode.system,
         merchantDisplayName: 'Merchant Display Name',
       ),
     )
         .then((value) {
       showPaymentSheetWidget();
     });
   } catch (exe, s) {
     debugPrint('Exception:$exe$s');
   }
 }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          CardField(
            onCardChanged: (card) {
              print(card);
            },
          ),
          TextButton(
            onPressed: () async {
              // create payment method
              final paymentMethod = await Stripe.instance
                  .createPaymentMethod();
            },
            child: Text('pay'),
          )
        ],
      ),
    );
  }
}
