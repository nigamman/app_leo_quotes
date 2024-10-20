class UserData {
  String name;
  int age; // Define age field
  List<String> selectedCategories; // Define selectedCategories field
  String frequency; // Define frequency field
  String notificationTime; // Define notificationTime field

  UserData({
    required this.name,
    required this.age,
    required this.selectedCategories,
    required this.frequency,
    required this.notificationTime, // Add notificationTime to the constructor
  });

  // From Firebase JSON
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      name: json['name'],
      age: json['age'] ?? 0,
      selectedCategories: List<String>.from(json['selectedCategories'] ?? []),
      frequency: json['frequency'] ?? '',
      notificationTime: json['notificationTime'] ?? '', // Deserialize notificationTime
    );
  }

  // To Firebase JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'selectedCategories': selectedCategories,
      'frequency': frequency,
      'notificationTime': notificationTime, // Serialize notificationTime
    };
  }
}
