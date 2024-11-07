import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:untitled5/services/notification_service.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package

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
          content: const Text('Do you want to turn off notifications?'),
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
      setState(() {
        isReminderEnabled = false;
      });
      await _saveReminderState(false);
      _notificationService.cancelNotification(); // Cancel notifications
    }
  }

  // Function to launch Play Store
  Future<void> _rateApp() async {
    const String url = 'https://play.google.com/store/apps/details?id=com.nigamman.leoquotes'; // Replace with your app's package name
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
              onToggle: (value) {
                if (value) {
                  setState(() => isReminderEnabled = true);
                  _saveReminderState(true);
                } else {
                  _showDisableReminderDialog();
                }
              },
            ),
            const SizedBox(height: 20),
            _buildRateUsSection(), // Add Rate Us section
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
          leading: Image.asset('assets/icons/info.png', height: 40, width: 40),
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

  // New Rate Us section
  Widget _buildRateUsSection() {
    return GestureDetector(
      onTap: _rateApp,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        child: ListTile(
          leading: const Icon(Icons.star_rate, size: 40, color: Colors.deepOrange),
          title: Text('Rate Us on Play Store', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepOrange),
        ),
      ),
    );
  }
  Widget _buildInfoRow(String title, String value, Icon icon) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 10),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$title: ', // Title text with grey color
                style: GoogleFonts.poppins(fontSize: 17, color: Colors.grey), // Change color here
              ),
              TextSpan(
                text: value, // Value text with default color
                style: GoogleFonts.poppins(fontSize: 19), // Keep default style for value
              ),
            ],
          ),
        ),
      ],
    );
  }
}