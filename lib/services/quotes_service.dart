import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class QuotesService with ChangeNotifier {
  final DatabaseReference _quotesRef = FirebaseDatabase.instance.ref('quotes');
  List<String> quotesList = [];

  Future<void> fetchQuotes() async {
    try {
      DatabaseEvent event = await _quotesRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        // Assuming the quotes are structured as described
        List<dynamic> quotesArray = snapshot.value as List<dynamic>;

        List<String> tempList = [];

        for (var quoteObj in quotesArray) {
          if (quoteObj != null && quoteObj is Map) {
            // Access the 'text' field which is a map of quotes
            Map<dynamic, dynamic> quotesMap = quoteObj['text'];

            // Iterate through the quotes in the map
            quotesMap.forEach((key, value) {
              if (value != null && value is String) {
                tempList.add(value); // Collect the quote text
              }
            });
          }
        }

        quotesList = tempList; // Update quotes list
        notifyListeners(); // Notify listeners about the update
      } else {
        quotesList = []; // or handle no quotes found
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching quotes: $e");
    }
  }
}
