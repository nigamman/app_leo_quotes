import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Custom fonts
import 'package:untitled5/services/quote_manager.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences
import 'home_page.dart'; // HomePage import

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<String> selectedCategories = [];
  bool isSelectionSaved = false;
  final QuoteManager _quoteManager = QuoteManager();
  double _opacity = 0.0; // Variable to control opacity

  @override
  void initState() {
    super.initState();
    _loadSelectedCategories();
  }

  // Load previously selected categories from SharedPreferences
  Future<void> _loadSelectedCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedCategories = prefs.getStringList('selectedCategories');
    if (savedCategories != null) {
      setState(() {
        selectedCategories = savedCategories;
        isSelectionSaved = true; // Set to true if categories were loaded
        _opacity = 1.0; // Change opacity to fully visible
      });
    }
  }

  // Save selected categories to SharedPreferences and navigate to HomePage
  Future<void> _saveSelectedCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('selectedCategories', selectedCategories);
    setState(() {
      isSelectionSaved = true;
    });

    // Fetch and save a random quote from Firebase
    String fetchedQuote = await _quoteManager.fetchQuoteFromDatabase(selectedCategories);

    // Show confirmation SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your selection has been saved!'),
        duration: Duration(seconds: 1),
      ),
    );

    // Navigate to HomePage with selected categories
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(selectedCategories: selectedCategories),
      ),
          (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  void _toggleCategorySelection(String categoryName) {
    if (isSelectionSaved) {
      _showChangeSelectionDialog(categoryName);
    } else {
      _modifyCategorySelection(categoryName);
    }
  }

  void _modifyCategorySelection(String categoryName) {
    setState(() {
      if (selectedCategories.contains(categoryName)) {
        selectedCategories.remove(categoryName);
      } else {
        if (selectedCategories.length < 3) {
          selectedCategories.add(categoryName);
        } else {
          _showSelectionLimitDialog();
        }
      }
      isSelectionSaved = false; // Mark selection as not saved
    });
  }

  void _showChangeSelectionDialog(String categoryName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Selection'),
          content: const Text('Do you want to change your previously saved categories?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedCategories.clear();
                  selectedCategories.add(categoryName);
                  isSelectionSaved = false; // Mark as not saved since it's a new selection
                });
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showSelectionLimitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selection Limit'),
          content: const Text('You can select a maximum of 3 categories.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canShowSaveButton = selectedCategories.isNotEmpty && !isSelectionSaved;

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text('Categories', style: GoogleFonts.lobster(color: Colors.white, fontSize: 28)),
        backgroundColor: Colors.deepOrange.shade700,
        elevation: 0,
      ),
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 500), // Duration of the fade-in animation
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategories.contains(category.name);

            return GestureDetector(
              onTap: () {
                _toggleCategorySelection(category.name);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.deepOrangeAccent[700] : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      category.iconPath,
                      height: 60,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        category.name,
                        style: GoogleFonts.dancingScript(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center, // Center-align the text within the Text widget
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: canShowSaveButton
          ? ElevatedButton(
            onPressed: _saveSelectedCategories,
            style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrangeAccent[700],
          ),
             child: const Text('Save', style: TextStyle(fontSize: 16,
               fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Roboto'),
          ),
        ) : null,
    );
  }
}

class Category {
  final String name;
  final String iconPath;

  Category({required this.name, required this.iconPath});
}

List<Category> categories = [
  Category(name: 'General', iconPath: 'assets/images/gen.ico'),
  Category(name: 'Hustle', iconPath: 'assets/images/hustle.ico'),
  Category(name: 'Fitness', iconPath: 'assets/images/fit.ico'),
  Category(name: 'Life', iconPath: 'assets/images/balance.ico'),
  Category(name: 'Loneliness', iconPath: 'assets/images/alone.ico'),
  Category(name: 'Financial Growth', iconPath: 'assets/images/money.ico'),
  Category(name: 'Relationship', iconPath: 'assets/images/love2.ico'),
  Category(name: 'Control Stress', iconPath: 'assets/images/stress.ico'),
];
