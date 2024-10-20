import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled5/pages/home_page.dart';
import 'package:untitled5/introPages/first_welcome.dart';
import 'package:untitled5/introPages/intro_name.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart'; // OneSignal import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize OneSignal
  OneSignal.shared.setAppId("2baf62e7-967f-4a53-9412-e8c4df05f45c");

  // Optional: Prompt the user for notification permission
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    print("Permission accepted: $accepted");
  });

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
//
// class CheckIntroStatus extends StatefulWidget {
//   const CheckIntroStatus({super.key});
//
//   @override
//   _CheckIntroStatusState createState() => _CheckIntroStatusState();
// }
//
// class _CheckIntroStatusState extends State<CheckIntroStatus> {
//   UserService userService = UserService();
//   UserData? userData;
//   List<String> selectedCategories = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserDataAndGoToIntro();
//   }
//
//   void _loadUserDataAndGoToIntro() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String name = prefs.getString('name') ?? 'Not Set';
//     int age = prefs.getInt('age') ?? 0;
//
//     // Ensure categories are loaded as a list
//     List<String> categories = prefs.getStringList('selectedCategories') ?? [];
//
//     String frequency = prefs.getString('frequency') ?? '';
//     String notificationTime = prefs.getString('notificationTime') ?? '';
//
//     userData = UserData(
//       name: name,
//       age: age,
//       selectedCategories: categories,
//       frequency: frequency,
//       notificationTime: notificationTime,
//     );
//
//     // Initialize notifications with userData
//     await NotificationService().initNotification(context, userData!.name);
//
//     // Navigate to the WelcomePage
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const WelcomePage(),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
//
//   void _completeIntro() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isFirstLaunch', false);
//   }
// }

class CheckIntroStatus extends StatefulWidget {
  const CheckIntroStatus({super.key});

  @override
  _CheckIntroStatusState createState() => _CheckIntroStatusState();
}

class _CheckIntroStatusState extends State<CheckIntroStatus> {
  bool _isFirstLaunch = true;  // Default value
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
        ? const WelcomePage()  // Show intro if first launch
        : HomePage(selectedCategories: selectedCategories);  // Otherwise, go to home page
  }
}


// Update this method in the last intro page to mark the intro as completed
void _completeIntro() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isFirstLaunch', false);  // Ensure this is saved
}

