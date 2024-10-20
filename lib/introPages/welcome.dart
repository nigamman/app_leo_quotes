import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled5/models/user_data.dart';
import 'package:untitled5/pages/home_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart'; // Add this import

class WelcomePage extends StatefulWidget {
  final UserData userData;

  const WelcomePage({super.key, required this.userData});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  bool _isLoading = false; // Loading state
  String greetingText = ''; // Text for greeting message
  late ConfettiController _confettiController; // Confetti controller
  late AnimationController _appNameController; // App name animation controller
  late AnimationController _iconController; // Icon animation controller
  late Animation<Offset> _appNameOffsetAnimation; // App name animation
  late Animation<double> _iconScaleAnimation; // Icon scale animation

  @override
  void initState() {
    super.initState();

    // App Name Animation
    _appNameController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _appNameOffsetAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _appNameController,
        curve: Curves.easeInOut,
      ),
    );
    _appNameController.forward(); // Start the app name animation

    // App Icon Animation
    _iconController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _iconScaleAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    _iconController.repeat(reverse: true); // Repeat the icon animation

    _startTypingGreeting();
    _confettiController = ConfettiController(duration: const Duration(seconds: 7)); // Initialize confetti controller
  }

  @override
  void dispose() {
    _confettiController.dispose(); // Dispose of the confetti controller
    _appNameController.dispose(); // Dispose app name animation controller
    _iconController.dispose(); // Dispose icon animation controller
    super.dispose();
  }

  // Function to start typewriter animation for greeting
  void _startTypingGreeting() {
    String name = widget.userData.name.isNotEmpty ? widget.userData.name : 'User';
    String welcomeMessage = 'Welcome back, $name!';
    int currentIndex = 0;

    // Timer to simulate typewriter effect
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (currentIndex < welcomeMessage.length) {
        setState(() {
          greetingText += welcomeMessage[currentIndex];
          currentIndex++;
        });
      } else {
        timer.cancel();
        _confettiController.play(); // Play confetti animation when greeting is complete
      }
    });
  }

  // Function to save user data to Firebase
  Future<void> _saveUserData(UserData userData) async {
    try {
      if (userData.name.isEmpty || userData.age <= 0) {
        throw Exception('Invalid user data');
      }

      final databaseRef = FirebaseDatabase.instance.ref().child('users/${userData.name}');
      await databaseRef.set(userData.toJson());
      print('User data saved to Firebase');
    } catch (e) {
      print('Error saving user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save user data')),
      );
    }
  }

  // Function to mark intro as completed
  Future<void> _completeIntro(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstLaunch', false); // Mark intro as completed
      print('isFirstLaunch set to false');

      // Save user data to Firebase
      await _saveUserData(widget.userData);

      // Navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            selectedCategories: widget.userData.selectedCategories ?? [], // Provide a default empty list if null
          ),
        ),
      );
    } catch (e) {
      print('Error completing intro: $e');
    }
  }

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
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

          // Confetti widget
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14 / 2, // 90 degrees
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.3,
          ),

          // Animated App Name (Leo Quotes)
          Positioned(
            top: 60,
            left: 16,
            child: SlideTransition(
              position: _appNameOffsetAnimation,
              child: Text(
                'Leo Quotes',
                style: GoogleFonts.lobster(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated app icon
                ScaleTransition(
                  scale: _iconScaleAnimation,
                  child: Image.asset(
                    'assets/icons/leo_app.png', // Replace with your app icon path
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 20),

                // Greeting message with typewriter effect
                Text(
                  greetingText,
                  style: GoogleFonts.lobster(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // Progress indicator
                LinearProgressIndicator(
                  value: 1.0, // Completed progress
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your profile is good to go!',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                    _toggleLoading();
                    await _completeIntro(context);
                    _toggleLoading();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    backgroundColor: Colors.deepOrange.shade50,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Go to App', style: TextStyle(color: Colors.black)),
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
