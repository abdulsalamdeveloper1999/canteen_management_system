import 'package:canteen_food_ordering_app/firebase_options.dart';
import 'package:canteen_food_ordering_app/notifiers/image_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:canteen_food_ordering_app/screens/landingPage.dart';
import 'package:provider/provider.dart';
import 'new_added_features/apis/impl/user_orders_impl.dart';
import 'notifiers/authNotifier.dart';

void main() async {
  // Ensures bindings are initialized before making asynchronous calls
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final userOrdersService = UserOrdersServiceImpl();

  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    print(uid);
    final orders = await userOrdersService.retrieveUserOrders(uid);
    print('User Orders: $orders');
  } catch (e) {
    print('Error: $e');
  }

  // Run the app with providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthNotifier(),
        ),
        ChangeNotifierProvider(
          create: (context) => ImagePickerProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cassia',
      theme: ThemeData(
        fontFamily: 'Montserrat', // Ensure this font is added to pubspec.yaml
        primaryColor: const Color.fromRGBO(255, 63, 111, 1),
      ),
      home: LandingPage(),
    );
  }
}
