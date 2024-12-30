import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled5/models/user_data.dart';
import 'package:untitled5/pages/home_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

class WelcomePage extends StatefulWidget {
  final UserData userData;

  const WelcomePage({super.key, required this.userData});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isButtonEnabled = false;
  String greetingText = '';
  late ConfettiController _leftConfettiController;
  late ConfettiController _rightConfettiController;
  late AnimationController _logoController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _isLogoControllerInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize ConfettiControllers for left and right sides
    _leftConfettiController = ConfettiController(duration: const Duration(seconds: 2));
    _rightConfettiController = ConfettiController(duration: const Duration(seconds: 2));

    // Logo Animation Controller
    _logoController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _isLogoControllerInitialized = true;

    // Progress Bar Animation Controller
    _progressController = AnimationController(
      duration: const Duration(seconds: 3), // Duration adjusted for smoother flow
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Start progress animation
    _progressController.forward().whenComplete(() {
      // Ensure confetti controllers are called after the progress bar is filled
      _leftConfettiController.play();
      _rightConfettiController.play();
      setState(() {
        _isButtonEnabled = true; // Enable button after confetti animation
      });
    });

    // Start typing greeting message
    _startTypingGreeting();
  }

  @override
  void dispose() {
    _leftConfettiController.dispose();
    _rightConfettiController.dispose();
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  // Function to start typewriter animation for greeting
  void _startTypingGreeting() {
    String name = widget.userData.name.isNotEmpty ? widget.userData.name : 'User';
    String welcomeMessage = 'Welcome back, $name!';
    int currentIndex = 0;

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (currentIndex < welcomeMessage.length) {
        setState(() {
          greetingText += welcomeMessage[currentIndex];
          currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _completeIntro(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstLaunch', false);

      await _saveUserData(widget.userData);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            selectedCategories: widget.userData.selectedCategories ?? [],
          ),
        ),
      );
    } catch (e) {
      print('Error completing intro: $e');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange.shade400, Colors.deepOrange.shade700],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Abstract Shapes
          _buildAbstractShape(top: -50, left: -50, size: 200, opacity: 0.1, right: 0),
          _buildAbstractShape(top: 100, right: -30, size: 150, opacity: 0.2),
          _buildAbstractShape(top: 300, left: 80, size: 250, opacity: 0.15, right: 0),
          _buildAbstractShape(bottom: 50, right: 50, size: 160, opacity: 0.2, top: 0.1),

          // Left Confetti
          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _leftConfettiController,
              blastDirection: 0, // Left blast
              particleDrag: 0.05,
              emissionFrequency: 0.6,
              numberOfParticles: 10,
              gravity: 0.5,
            ),
          ),

          // Right Confetti
          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _rightConfettiController,
              blastDirection: 3.14, // Right blast
              particleDrag: 0.05,
              emissionFrequency: 0.6,
              numberOfParticles: 10,
              gravity: 0.5,
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Animation
                if (_isLogoControllerInitialized)
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0).animate(_logoController),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: 15,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/icons/leo_app.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Greeting Message with Typewriter Animation
                AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  child: Text(
                    greetingText,
                    key: ValueKey<String>(greetingText),
                    style: GoogleFonts.lobster(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Progress Bar
                CircularProgressIndicator(
                  value: _progressAnimation.value,
                  strokeWidth: 8,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
                const SizedBox(height: 10),
                Text(
                  '${(_progressAnimation.value * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 30),

                // Go to App Button
                ElevatedButton(
                  onPressed: _isButtonEnabled
                      ? () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await _completeIntro(context);
                    setState(() {
                      _isLoading = false;
                    });
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    backgroundColor: Colors.deepOrange.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Get Started', style: TextStyle(color: Colors.black)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.black),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
