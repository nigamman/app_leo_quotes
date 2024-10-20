// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:untitled5/services/notification_service.dart';
// import 'package:untitled5/services/user_service.dart';
// import 'package:permission_handler/permission_handler.dart'; // Import for permission handling
//
// class SettingsPage extends StatefulWidget {
//   const SettingsPage({super.key});
//
//   @override
//   _SettingsPageState createState() => _SettingsPageState();
// }
//
// class _SettingsPageState extends State<SettingsPage> {
//   bool isReminderEnabled = false;
//   String _reminderTime = 'Not Set';
//   String _name = 'Not Set';
//   int _age = 0;
//   String _selectedFrequency = 'Not Set';
//
//   final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
//   final NotificationService _notificationService = NotificationService();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserInfo();
//     _notificationService.initNotification(context); // Initialize notifications
//     _requestNotificationPermission(); // Request notification permission
//   }
//
//   Future<void> _requestNotificationPermission() async {
//     if (await Permission.notification.request().isGranted) {
//       // Permission granted
//     } else {
//       // Handle permission denial
//       print("Notification permission denied.");
//     }
//   }
//
//   Future<void> _loadUserInfo() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _name = prefs.getString('name') ?? 'Not Set';
//       _age = prefs.getInt('age') ?? 0;
//       _selectedFrequency = prefs.getString('selectedFrequency') ?? 'Not Set';
//       isReminderEnabled = prefs.getBool('remindersEnabled') ?? false;
//       _reminderTime = prefs.getString('notificationTime') ?? 'Not Set';
//     });
//
//     // Debug: Check initial reminder time from SharedPreferences
//     print("Initial reminder time from SharedPreferences: $_reminderTime");
//
//     // Load reminder time from Firebase
//     final userId = _name; // Or use a proper user identifier
//     final snapshot = await _databaseRef.child('users/$userId/reminder').once();
//     if (snapshot.snapshot.exists) {
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
//       setState(() {
//         _reminderTime = data['time'] ?? 'Not Set'; // Retrieve reminder time
//       });
//
//       // Debug: Check if reminder time is correctly updated from Firebase
//       print("Reminder time from Firebase: $_reminderTime");
//     }
//   }
//
//   Future<void> _saveReminderState(bool enabled) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('remindersEnabled', enabled);
//
//     // Save the reminder time in Firebase whenever the state changes
//     await _saveReminderToFirebase(enabled, _reminderTime);
//   }
//
//   Future<void> _saveReminderToFirebase(bool enabled, String time) async {
//     String userId = _name; // Use name as the identifier (or use a Firebase Auth ID)
//     await _databaseRef.child('users/$userId/reminder').set({
//       'enabled': enabled,
//       'time': time,
//     });
//   }
//
//   Future<void> _showDisableReminderDialog() async {
//     bool? result = await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Turn Off Notifications'),
//           content: const Text('Do you want to turn off notifications?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('No'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('Yes'),
//             ),
//           ],
//         );
//       },
//     );
//     if (result == true) {
//       setState(() {
//         isReminderEnabled = false;
//         _reminderTime = 'Not Set';
//       });
//       await _saveReminderState(false);
//       _notificationService.cancelNotification(); // Cancel notifications
//     }
//   }
//
//   Future<void> _showSetReminderTimeDialog() async {
//     TimeOfDay? selectedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (selectedTime != null) {
//       // Update the _reminderTime variable and save it
//       setState(() {
//         _reminderTime = '${selectedTime.hour}:${selectedTime.minute}'; // Update your time format
//       });
//       await _saveReminderToFirebase(isReminderEnabled, _reminderTime);
//       _notificationService.scheduleNotification(selectedTime); // Schedule notification with the new time
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.orange.shade50,
//       appBar: AppBar(
//         title: Text('Settings', style: GoogleFonts.lobster(color: Colors.white, fontSize: 28)),
//         backgroundColor: Colors.deepOrange.shade700,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             _buildPersonalInfoSection(),
//             const SizedBox(height: 20),
//             _buildAddWidgetSection(),
//             const SizedBox(height: 20),
//             _buildSettingCard(
//               title: 'Set Reminder',
//               icon: isReminderEnabled ? Icons.notifications_active : Icons.notifications_off,
//               subtitle: isReminderEnabled ? 'Reminder set for $_reminderTime' : 'Enable reminders',
//               toggleValue: isReminderEnabled,
//               onToggle: (value) async {
//                 if (value) {
//                   if (_reminderTime == 'Not Set') {
//                     // Prompt user to set reminder time
//                     await _showSetReminderTimeDialog();
//                     return; // Don't schedule if time is not set
//                   }
//                   setState(() => isReminderEnabled = true);
//                   await _saveReminderState(true);
//
//                   // Parse _reminderTime and schedule the notification
//                   TimeOfDay reminderTime = _parseReminderTime(_reminderTime);
//
//                   // Debug: Check the time being passed to notification scheduling
//                   print("Scheduling notification for time: ${reminderTime.hour}:${reminderTime.minute}");
//
//                   _notificationService.scheduleNotification(reminderTime); // Schedule notification
//                 } else {
//                   _showDisableReminderDialog();
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSettingCard({
//     required String title,
//     required IconData icon,
//     required String subtitle,
//     required bool toggleValue,
//     required Function(bool) onToggle,
//   }) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       elevation: 8,
//       child: ListTile(
//         leading: Icon(icon, size: 40, color: Colors.deepOrange),
//         title: Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
//         subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600)),
//         trailing: Switch(
//           value: toggleValue,
//           onChanged: onToggle,
//           activeColor: Colors.deepOrange,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPersonalInfoSection() {
//     return GestureDetector(
//       onTap: () {
//         showModalBottomSheet(
//           context: context,
//           builder: (context) {
//             return Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.orange.shade50,
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildInfoRow('Name', _name, Icon(Icons.person, color: Colors.deepOrange)),
//                   const SizedBox(height: 10),
//                   _buildInfoRow('Age', _age.toString(), const Icon(Icons.cake, color: Colors.deepOrange)),
//                   const SizedBox(height: 10),
//                   _buildInfoRow('Frequency', _selectedFrequency, const Icon(Icons.access_time, color: Colors.deepOrange)),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         elevation: 8,
//         child: ListTile(
//           leading: Image.asset('assets/icons/info.png', height: 40, width: 40),
//           title: Text('Your Information', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
//           trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepOrange),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAddWidgetSection() {
//     return GestureDetector(
//       onTap: () {
//         showModalBottomSheet(
//           context: context,
//           builder: (context) {
//             return Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.orange.shade50,
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     'How to Add Widget to Home Screen',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text('1. Long press on the home screen.', style: TextStyle(fontSize: 16)),
//                   const Text('2. Select Widgets from the menu.', style: TextStyle(fontSize: 16)),
//                   const Text('3. Find and select your desired widget.', style: TextStyle(fontSize: 16)),
//                   const Text('4. Place it on your home screen.', style: TextStyle(fontSize: 16)),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         elevation: 8,
//         child: ListTile(
//           leading: Image.asset('assets/icons/widget.png', height: 40, width: 40),
//           title: Text('Add Widget Instructions', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
//           trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepOrange),
//         ),
//       ),
//     );
//   }
//   Widget _buildInfoRow(String title, String value, Icon icon) {
//     return Row(
//       children: [
//         icon,
//         const SizedBox(width: 10),
//         Text('$title: $value', style: GoogleFonts.poppins(fontSize: 16)),
//       ],
//     );
//   }
//
//   TimeOfDay _parseReminderTime(String time) {
//     if (time == 'Not Set') return TimeOfDay.now();
//     final parts = time.split(':');
//     return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:untitled5/services/notification_service.dart';

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

  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? 'Not Set';
      _age = prefs.getInt('age') ?? 0;
      _selectedFrequency = prefs.getString('selectedFrequency') ?? 'Not Set';
      isReminderEnabled = prefs.getBool('remindersEnabled') ?? false;
    });

    _notificationService.initNotification(context,_name);

    // Load reminder state from Firebase if needed
    final userId = _name; // Or use a proper user identifier
    final snapshot = await _databaseRef.child('users/$userId/reminder').once();
    if (snapshot.snapshot.exists) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        isReminderEnabled = data['enabled'] ?? false; // Retrieve reminder state
      });
    }
  }

  Future<void> _saveReminderState(bool enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remindersEnabled', enabled);

    // Save the reminder state in Firebase whenever the state changes
    await _saveReminderToFirebase(enabled);
  }

  Future<void> _saveReminderToFirebase(bool enabled) async {
    String userId = _name; // Use name as the identifier (or use a Firebase Auth ID)
    await _databaseRef.child('users/$userId/reminder').set({
      'enabled': enabled,
    });
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
            // Reminder section
            ListTile(
              title: const Text('Enable Reminders'),
              trailing: Switch(
                value: isReminderEnabled,
                onChanged: (value) {
                  setState(() {
                    isReminderEnabled = value;
                  });
                  _saveReminderState(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Personal Info', style: GoogleFonts.lobster(fontSize: 24)),
            const SizedBox(height: 10),
            Text('Name: $_name', style: const TextStyle(fontSize: 18)),
            Text('Age: $_age', style: const TextStyle(fontSize: 18)),
            Text('Reminder Frequency: $_selectedFrequency', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
