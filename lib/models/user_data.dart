class UserData {
  String name;
  int age;
  List<String> selectedCategories;
  String frequency;
  String notificationTime;
  String fcmToken; // Add fcmToken field

  UserData({
    required this.name,
    required this.age,
    required this.selectedCategories,
    required this.frequency,
    required this.notificationTime,
    required this.fcmToken, // Add fcmToken to the constructor
  });

  // From Firebase JSON
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      name: json['name'],
      age: json['age'] ?? 0,
      selectedCategories: List<String>.from(json['selectedCategories'] ?? []),
      frequency: json['frequency'] ?? '',
      notificationTime: json['notificationTime'] ?? '',
      fcmToken: json['fcmToken'] ?? '',
    );
  }

  // To Firebase JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'selectedCategories': selectedCategories,
      'frequency': frequency,
      'notificationTime': notificationTime,
      'fcmToken': fcmToken,
    };
  }
}
