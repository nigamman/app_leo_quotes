import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled5/pages/home_page.dart';
import 'package:untitled5/introPages/first_welcome.dart';
import 'package:untitled5/introPages/intro_name.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart'; // OneSignal import

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Initialize Firebase if not already initialized
    try {
      await Firebase.initializeApp();

      // Fetch a random quote from Firebase
      final DatabaseReference _quoteRef = FirebaseDatabase.instance.ref('quotes/0/text');
      DataSnapshot snapshot = await _quoteRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> quotes = Map<String, dynamic>.from(snapshot.value as Map);
        List<String> quoteList = quotes.values.toList().cast<String>();

        String randomQuote = quoteList[Random().nextInt(quoteList.length)];

        // Save the quote in HomeWidget storage and update the widget
        await HomeWidget.saveWidgetData<String>('quote', randomQuote);
        await HomeWidget.updateWidget(
          name: 'QuoteHomeWidgetProvider',
          androidName: 'QuoteHomeWidgetProvider',
        );
      } else {
        print("No quotes found in Firebase.");
      }
    } catch (e) {
      print("Error in WorkManager task: $e");
    }

    return Future.value(true);
  });
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize OneSignal
  OneSignal.shared.setAppId("8de30895-cf2a-46e9-b898-5782813f5be6");


  // Initialize WorkManager
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // Schedule periodic background task to fetch and update the widget
  Workmanager().registerPeriodicTask(
    "1", // Unique task name
    "fetchAndUpdateQuote", // Task name
    frequency: const Duration(minutes: 270), // Minimum is 15 minutes
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Leo Quotes',
      home: const CheckIntroStatus(),
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/namePage': (context) => const IntroPageName(),
      },
    );
  }
}

class CheckIntroStatus extends StatefulWidget {
  const CheckIntroStatus({super.key});

  @override
  _CheckIntroStatusState createState() => _CheckIntroStatusState();
}

class _CheckIntroStatusState extends State<CheckIntroStatus> {
  bool _isFirstLaunch = true; // Default value
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _checkIfFirstLaunch();
  }

  // Check if the introduction has already been shown
  void _checkIfFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load the value of 'isFirstLaunch', default to true if not present
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      setState(() {
        _isFirstLaunch = true;
      });
    } else {
      _goToHomePage();
    }
  }

  // Save selected categories and move to HomePage
  void _goToHomePage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedCategories = prefs.getStringList('selectedCategories') ?? [];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(selectedCategories: selectedCategories),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isFirstLaunch
        ? const WelcomePage() // Show intro if first launch
        : HomePage(selectedCategories: selectedCategories); // Otherwise, go to home page
  }
}

// Update this method in the last intro page to mark the intro as completed
void _completeIntro() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isFirstLaunch', false); // Ensure this is saved
}