import 'package:canteen_food_ordering_app/apis/foodAPIs.dart';
import 'package:canteen_food_ordering_app/notifiers/authNotifier.dart';
import 'package:canteen_food_ordering_app/screens/adminHome.dart';
import 'package:canteen_food_ordering_app/screens/login.dart';
import 'package:canteen_food_ordering_app/screens/navigationBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    // Initialize current user without triggering rebuilds
    Future.microtask(() {
      final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
      initializeCurrentUser(authNotifier, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the AuthNotifier
    final authNotifier = Provider.of<AuthNotifier>(context);

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(255, 138, 120, 1),
              Color.fromRGBO(255, 114, 117, 1),
              Color.fromRGBO(255, 63, 111, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Cassia',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily:
                    'MuseoModerno', // Ensure this font is added to pubspec.yaml
              ),
            ),
            const SizedBox(height: 140),
            GestureDetector(
              onTap: () {
                // Handle navigation based on user state
                if (authNotifier.user == null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                } else {
                  final route = authNotifier.userDetails.role == 'admin'
                      ? MaterialPageRoute(builder: (_) => AdminHomePage())
                      : MaterialPageRoute(
                          builder: (_) => NavigationBarPage(selectedIndex: 1),
                        );
                  Navigator.pushReplacement(context, route);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "Explore",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(255, 63, 111, 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
