import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled5/pages/home_page.dart';
import 'package:untitled5/introPages/first_welcome.dart';
import 'package:untitled5/introPages/intro_name.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:in_app_update/in_app_update.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("8de30895-cf2a-46e9-b898-5782813f5be6");
  FirebaseDatabase.instance.setPersistenceEnabled(true);
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
        '/home': (context) => const HomePage(selectedCategories: []),
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

  Future<void> clearLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all saved data in SharedPreferences
  }

  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    _checkIfFirstLaunch();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkForUpdate(context); // Check for updates
    });
  }

  void _checkIfFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      await clearLocalData(); // Clear data when user reinstalls the app
      prefs.setBool('isFirstLaunch', false); // Mark first launch as completed
      setState(() {
        _isFirstLaunch = true;
      });
    } else {
      _goToHomePage();
    }
  }

  void _goToHomePage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> selectedCategories = prefs.getStringList('selectedCategories') ?? [];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(selectedCategories: selectedCategories),
      ),
    );
  }

  void checkForUpdate(BuildContext context) async {
    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
          InAppUpdate.completeFlexibleUpdate();
        }
      }
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isFirstLaunch
        ? const WelcomePage()
        : FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          SharedPreferences prefs = snapshot.data as SharedPreferences;
          List<String> categories = prefs.getStringList('selectedCategories') ?? [];
          return HomePage(selectedCategories: categories);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
