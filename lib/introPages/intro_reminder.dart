import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled5/introPages/welcome.dart';
import 'package:untitled5/models/user_data.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled5/services/user_service.dart';
import 'package:untitled5/services/notification_service.dart';

class IntroPageReminder extends StatefulWidget {
  final UserData userData;

  const IntroPageReminder({super.key, required this.userData});

  @override
  _IntroPageReminderState createState() => _IntroPageReminderState();
}

class _IntroPageReminderState extends State<IntroPageReminder> {
  Future<void> _requestNotificationPermission(BuildContext context) async {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      await NotificationService().initNotification(context, widget.userData.name); // Initialize notifications
      await _saveReminderPreference(true, context); // Save preference after permission is granted
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission denied.')),
      );
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission permanently denied. Please enable it in settings.')),
      );
      openAppSettings(); // Redirect user to app settings
    }
  }

  Future<void> _saveReminderPreference(bool enabled, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save to SharedPreferences
    await prefs.setBool('remindersEnabled', enabled);

    // Save to Firebase
    UserService userService = UserService();
    try {
      await userService.saveUserData(
        widget.userData.name, // Use user's name as the key
        widget.userData.age,
        widget.userData.frequency,
        widget.userData.selectedCategories,
        widget.userData.notificationTime,
      );
      // Trigger the notification setup on Firebase
      await NotificationService().setupNotificationForUser(widget.userData.name); // Set up notifications in Firebase
    } catch (e) {
      print('Error saving user data to Firebase: $e');
    }

    // Provide feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder preference saved: ${enabled ? 'Enabled' : 'Disabled'}')),
    );

    // Navigate to the WelcomePage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage(userData: widget.userData)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange.shade400, Colors.deepOrange.shade700],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App logo
                Image.asset(
                  'assets/images/gen.ico', // Replace with your logo
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Enable Quote Reminders',
                  style: GoogleFonts.lobster(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Reminder message
                const Text(
                  'Would you like to receive daily reminders with inspiring quotes?',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Enable reminders button
                ElevatedButton(
                  onPressed: () {
                    _requestNotificationPermission(context); // Request permission
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Enable Reminders',
                    style: TextStyle(fontSize: 18, color: Colors.deepOrange),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _saveReminderPreference(false, context); // Save preference to skip reminders
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 30),

                // Motivational quote
                const Text(
                  '"We always need little reminders that it\'s gonna be all good."',
                  style: TextStyle(fontSize: 16, color: Colors.white70, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
