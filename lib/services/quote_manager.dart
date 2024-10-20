import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuoteManager {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Fetch a random quote based on the user's selected categories
  Future<String> fetchQuoteFromDatabase() async {
    String quote = "This is your quote."; // Default quote in case of failure
    try {
      // Retrieve the user's name from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userName = prefs.getString('name');

      if (userName != null && userName.isNotEmpty) {
        // Get the user's selected categories from Firebase
        DatabaseEvent userEvent = await _dbRef.child('users/$userName/selectedCategories').once();

        // Check if the snapshot exists and is a List
        if (userEvent.snapshot.exists && userEvent.snapshot.value != null) {
          final dynamic value = userEvent.snapshot.value;
          if (value is List) {
            // Cast to List<String>
            List<String> selectedCategories = List<String>.from(value);

            if (selectedCategories.isNotEmpty) {
              // Fetch quotes that match the selected categories
              DatabaseEvent quotesEvent = await _dbRef.child('quotes').once();
              if (quotesEvent.snapshot.exists && quotesEvent.snapshot.value is Map) {
                Map<String, dynamic> allQuotes = quotesEvent.snapshot.value as Map<String, dynamic>;

                // Filter quotes by the user's selected categories
                List<String> filteredQuotes = allQuotes.entries
                    .where((entry) => selectedCategories.contains(entry.key)) // Filter by category
                    .map((entry) => entry.value.toString())
                    .toList();

                // Randomize and pick one quote
                quote = filteredQuotes.isNotEmpty ? (filteredQuotes..shuffle()).first : quote;
              }
            }
          } else {
            print("Selected categories is not a list.");
          }
        } else {
          print("User event does not exist or has no value.");
        }
      }
    } catch (e) {
      print("Error fetching quote: $e");
    }
    return quote;
  }
}