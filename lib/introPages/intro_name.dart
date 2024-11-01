import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:untitled5/introPages/intro_age.dart';
import 'package:untitled5/models/user_data.dart';

class IntroPageName extends StatefulWidget {
  const IntroPageName({super.key});

  @override
  _IntroPageNameState createState() => _IntroPageNameState();
}

class _IntroPageNameState extends State<IntroPageName> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _storeName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
  }

  void _goToNextPage() {
    String name = _nameController.text.trim();

    if (name.isNotEmpty) {
      _storeName(name);

      int age = 0;
      List<String> selectedCategories = [];

      UserData userData = UserData(name: name, age: age, selectedCategories: selectedCategories, frequency: '', notificationTime: '', fcmToken: '');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => IntroPageAge(userData: userData),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient to match welcome page
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange.shade400, Colors.deepOrange.shade700],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Abstract shapes for design consistency
          _buildAbstractShape(top: -50, left: -50, size: 200, opacity: 0.1, right: 0),
          _buildAbstractShape(top: 100, right: -30, size: 150, opacity: 0.2),
          _buildAbstractShape(top: 300, left: 80, size: 250, opacity: 0.15, right: 0),
          _buildAbstractShape(bottom: 50, right: 50, size: 160, opacity: 0.2, top: 0),

          // Main content with top padding
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Animated Logo
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
                    'What\'s Your Name?',
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
                    value: 1/6, // Example progress
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 30),

                // Name TextField with icon
                FadeInUp(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Colors.white),
                      labelText: 'Your Name',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),

                // Motivational quote
                FadeInUp(
                  child: Text(
                    '"Your journey to inspiration starts here!"',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),

                // Next Button with icon and animation
                ElasticIn(
                  child: ElevatedButton.icon(
                    onPressed: _goToNextPage,
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

  // Abstract shapes similar to WelcomePage
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
