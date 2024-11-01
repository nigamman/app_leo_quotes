import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:untitled5/introPages/intro_frqn.dart';
import 'package:untitled5/models/user_data.dart';

class IntroPageCategories extends StatefulWidget {
  final UserData userData;
  const IntroPageCategories({super.key, required this.userData});

  @override
  _IntroPageCategoriesState createState() => _IntroPageCategoriesState();
}

class _IntroPageCategoriesState extends State<IntroPageCategories> {
  final List<String> _categories = [
    'General', 'Fitness', 'Control Stress', 'Hustle',
    'Life', 'Loneliness', 'Relationship', 'Financial Growth'
  ];
  final List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedCategories();
  }

  Future<void> _loadSelectedCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedCategories = prefs.getStringList('selectedCategories');
    if (savedCategories != null) {
      setState(() {
        _selectedCategories.addAll(savedCategories);
      });
    }
  }

  Future<void> _saveSelectedCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedCategories', _selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange.shade400, Colors.deepOrange.shade700],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Abstract background shapes
          _buildAbstractShape(top: -50, left: -50, size: 200, opacity: 0.1, right: 0),
          _buildAbstractShape(top: 100, right: -30, size: 150, opacity: 0.2),
          _buildAbstractShape(top: 300, left: 80, size: 250, opacity: 0.15, right: 0),
          _buildAbstractShape(bottom: 50, right: 50, size: 160, opacity: 0.2, top: 0),

          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Animated logo
                ZoomIn(
                  child: Hero(
                    tag: 'app-logo',
                    child: Image.asset(
                      'assets/icons/leo_app.png', // Replace with your logo
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title with animation
                FadeIn(
                  child: Text(
                    'Select Categories',
                    style: GoogleFonts.lobster(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),

                // Progress indicator
                FadeInUp(
                  child: LinearProgressIndicator(
                    value: 3/6, // Example progress, page 3 of 6
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 30),

                // Bubble-style category grid
                Expanded(
                  child: FadeInUp(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Two columns
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.0, // Controls bubble shape
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        String category = _categories[index];
                        bool isSelected = _selectedCategories.contains(category);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedCategories.remove(category);
                              } else {
                                _selectedCategories.add(category);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(25),
                              border: isSelected ? Border.all(color: Colors.deepOrange, width: 2) : null,
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.8),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected ? Colors.deepOrange : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Motivational quote
                FadeInUp(
                  child: Text(
                    '"Choose what inspires you!"',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),

                // Next button with icon and animation
                ElasticIn(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (_selectedCategories.isNotEmpty) {
                        widget.userData.selectedCategories = _selectedCategories;
                        await _saveSelectedCategories();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IntroPageFrequency(userData: widget.userData),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.arrow_forward, color: Colors.deepOrange),
                    label: const Text(
                      'Next',
                      style: TextStyle(fontSize: 18, color: Colors.deepOrange),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                      shadowColor: Colors.black,
                      elevation: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Abstract background shape method
  Widget _buildAbstractShape({
    required double top,
    required double right,
    double? left,
    double? bottom,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      right: right,
      left: left,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
    );
  }
}