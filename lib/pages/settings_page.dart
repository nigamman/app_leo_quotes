import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:untitled5/services/notification_service.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isReminderEnabled = false;
  String _name = 'Not Set';
  int _age = 0;
  String _selectedFrequency = 'Not Set';

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _notificationService.initNotification(context, _name);
    _checkNotificationStatus();
  }
  Future<void> _onToggleNotification(bool value) async {
    if (value) {
      await _openNotificationSettings();
      bool isEnabled = await _notificationService.isNotificationEnabled();

      setState(() {
        isReminderEnabled = isEnabled;
      });

      if (isEnabled) {
        await _saveReminderState(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable notifications in settings.')),
        );
      }
    } else {
      await _showDisableReminderDialog();
    }
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? 'Not Set';
      _age = prefs.getInt('age') ?? 0;
      _selectedFrequency = prefs.getString('selectedFrequency') ?? 'Not Set';
      isReminderEnabled = prefs.getBool('remindersEnabled') ?? false;
    });
  }

  Future<void> _saveReminderState(bool enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remindersEnabled', enabled);

    // Save the reminder state in Firebase
    await _saveReminderToFirebase(enabled);

    // Notify the user of the change
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(enabled ? 'Reminders are ON' : 'Reminders are OFF')),
    );
  }

  Future<void> _saveReminderToFirebase(bool enabled) async {
    String userId = _name; // Use name as the identifier (or use a Firebase Auth ID)
    await _databaseRef.child('users/$userId/reminder').set({
      'enabled': enabled,
    });
  }

  Future<void> _showDisableReminderDialog() async {
    bool? result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Turn Off Notifications'),
          content: const Text('Do you want to turn off notifications? This will open the device settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // Launch the app's notification settings page
      await _openNotificationSettings();

      // Check the notification permission status
      bool isEnabled = await _notificationService.isNotificationEnabled();

      // Update the app state based on the user's action
      setState(() {
        isReminderEnabled = isEnabled;
      });

      if (!isEnabled) {
        await _saveReminderState(false);
        _notificationService.cancelNotification(); // Cancel notifications
      }
    }
  }

  Future<void> _checkNotificationStatus() async {
    // Check if notifications are enabled at the system level
    bool isEnabled = await _notificationService.isNotificationEnabled();

    setState(() {
      isReminderEnabled = isEnabled;
    });

    // Save the updated status to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remindersEnabled', isEnabled);
  }

  Future<void> _openNotificationSettings() async {
    const AndroidIntent intent = AndroidIntent(
      action: 'android.settings.APP_NOTIFICATION_SETTINGS',
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
      arguments: {
        'android.provider.extra.APP_PACKAGE': 'com.nigamman.leoquotes',
      },
    );
    await intent.launch();

    // Delay to allow the user to make changes in settings
    await Future.delayed(const Duration(seconds: 2));

    // Recheck the notification status after returning from settings
    await _checkNotificationStatus();

    // Provide feedback to the user
    if (!isReminderEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable notifications in device settings.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications enabled successfully.')),
      );
    }
  }


  // Function to launch Play Store
  Future<void> _rateApp() async {
    const String url = 'https://play.google.com/store/apps/details?id=com.nigamman.leoquotes';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Function to launch Instagram
  Future<void> _followUsOnInstagram() async {
    const String instagramAppUrl = "instagram://user?username=leoquotes.app";
    const String instagramWebUrl = "https://www.instagram.com/leoquotes.app";

    try {
      // Attempt to open the Instagram app
      if (await canLaunchUrl(Uri.parse(instagramAppUrl))) {
        await launchUrl(Uri.parse(instagramAppUrl));
      } else if (await canLaunchUrl(Uri.parse(instagramWebUrl))) {
        // Fallback to web URL
        await launchUrl(Uri.parse(instagramWebUrl), mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch Instagram';
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.lobster(color: Colors.white, fontSize: 28)),
        backgroundColor: Colors.deepOrange.shade700,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildPersonalInfoSection(),
            const SizedBox(height: 20),
            _buildAddWidgetSection(),
            const SizedBox(height: 20),
            _buildSettingCard(
              title: 'Set Notification',
              icon: isReminderEnabled ? Icons.notifications_active : Icons.notifications_off,
              subtitle: isReminderEnabled ? 'Notification is ON' : 'Notification is OFF',
              toggleValue: isReminderEnabled,
              onToggle: _onToggleNotification,
            ),
            const SizedBox(height: 20),
            _buildRateUsSection(),
            const SizedBox(height: 20),
            _buildFollowUsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required IconData icon,
    required String subtitle,
    required bool toggleValue,
    required Function(bool) onToggle,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListTile(
          leading: Icon(icon, size: 40, color: Colors.deepOrange),
          title: Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600)),
          trailing: Switch(
            value: toggleValue,
            onChanged: onToggle,
            activeColor: Colors.deepOrange,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          backgroundColor: Colors.orange.shade50,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildInfoRow('Name', _name, const Icon(Icons.person, color: Colors.deepOrange)),
                  const SizedBox(height: 20),
                  _buildInfoRow('Age', _age.toString(), const Icon(Icons.cake, color: Colors.deepOrange)),
                  const SizedBox(height: 20),
                  _buildInfoRow('Frequency', _selectedFrequency, const Icon(Icons.access_time, color: Colors.deepOrange)),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context), // Close the modal
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: Text('Got it', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        child: ListTile(
          leading: Image.asset('assets/icons/info.png', height: 35, width: 35),
          title: Text('Your Information', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepOrange),
        ),
      ),
    );
  }

  Widget _buildAddWidgetSection() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          backgroundColor: Colors.orange.shade50,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'How to Add Widget to Home Screen',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text('1. Long press on the home screen.', style: GoogleFonts.poppins(fontSize: 16), textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Text('2. Select Widgets.', style: GoogleFonts.poppins(fontSize: 16), textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Text('3. Find the Leo Quotes widget and add it.', style: GoogleFonts.poppins(fontSize: 16), textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: Text('Got it', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        child: ListTile(
          leading: Image.asset('assets/icons/widget_icon.png', height: 40, width: 40),
          title: Text('Add Widget to Home Screen', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepOrange),
        ),
      ),
    );
  }

  Widget _buildRateUsSection() {
    return GestureDetector(
      onTap: _rateApp,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        child: ListTile(
          leading: Image.asset('assets/icons/rate2.png', height: 30, width: 30),
          title: Text('Rate Us on Play Store', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepOrange),
        ),
      ),
    );
  }

  Widget _buildFollowUsSection() {
    return GestureDetector(
      onTap: _followUsOnInstagram,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        child: ListTile(
          leading: Image.asset('assets/icons/instagram.png', height: 45, width: 45), // Add Instagram icon in your assets
          title: Text('Follow Us on Instagram', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepOrange),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Icon icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            icon,
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        Text(value, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade700)),
      ],
    );
  }
}
