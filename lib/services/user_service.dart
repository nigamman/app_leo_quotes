import 'package:firebase_database/firebase_database.dart';

class UserService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> saveUserData(String name, int age, String frequency, List<String> selectedCategories, String notificationTime, String fcmToken) async {
    print('Saving user data to Firebase...');
    print('Data to save: {age: $age, frequency: $frequency, selectedCategories: $selectedCategories, notificationTime: $notificationTime}');

    try {
      await _dbRef.child('users/$name').update({
        'age': age,
        'frequency': frequency,
        'selectedCategories': selectedCategories,
        'notificationTime': notificationTime, // Save the time as a string
        'fcmToken': fcmToken // Save the token here
      });
      print('Data successfully saved to Firebase');
    } catch (e) {
      print('Error saving data to Firebase: $e');
      rethrow;
    }
  }
  Future<void> saveFcmTokenToDatabase(String? token, String userName) async {
    if (token != null) {
      try {
        await _dbRef.child('users/$userName').update({
          'fcmToken': token,
        });
        print('FCM token successfully saved to Firebase');
      } catch (e) {
        print('Error saving FCM token to Firebase: $e');
      }
    }
  }
}
