import 'package:firebase_database/firebase_database.dart';

class QuoteManager {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Fetch a random quote based on the user's selected categories
  Future<String> fetchQuoteFromDatabase(List<String>? selectedCategories) async {
    String quote = "This is your quote."; // Default quote in case of failure

    try {
      if (selectedCategories == null || selectedCategories.isEmpty) {
        print("No categories selected.");
        return quote;
      }

      // Fetch quotes that match the selected categories
      DatabaseEvent quotesEvent = await _dbRef.child('quotes').once();
      if (quotesEvent.snapshot.exists && quotesEvent.snapshot.value is Map) {
        Map<String, dynamic> allQuotes = quotesEvent.snapshot.value as Map<String, dynamic>;

        // Filter quotes by the user's selected categories
        List<String> filteredQuotes = allQuotes.entries
            .where((entry) => selectedCategories.contains(entry.key)) // Filter by category
            .expand((entry) {
          // Assuming each entry is a map with 'text' field containing multiple quotes
          var quotesMap = entry.value as Map<String, dynamic>;
          return quotesMap.values.map((quoteEntry) => quoteEntry['text'] as String).toList();
        })
            .toList();

        // Randomize and pick one quote
        if (filteredQuotes.isNotEmpty) {
          filteredQuotes.shuffle();
          quote = filteredQuotes.first;
        } else {
          print("No quotes found for selected categories.");
        }
      } else {
        print("No quotes found in the database.");
      }
    } catch (e) {
      print("Error fetching quote: $e");
    }

    return quote;
  }
}
