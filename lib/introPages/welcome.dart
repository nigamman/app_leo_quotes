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
  bool _isButtonEnabled = false;  // To control when the button becomes enabled
  String greetingText = '';
  late ConfettiController _confettiController;
  late AnimationController _logoController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _isLogoControllerInitialized = false;

  @override
  void initState() {
    super.initState();

    // Logo Animation Controller
    _logoController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);  // Ensuring it repeats back and forth
    _isLogoControllerInitialized = true;

    // Progress Bar Animation Controller
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _progressController.forward();  // Start the progress animation

    _startTypingGreeting();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));  // Confetti shortened

    // Enable the button after 4 seconds to allow animations to complete
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _isButtonEnabled = true;
      });
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();  // Clean up confetti
    _logoController.dispose();  // Clean up logo animation
    _progressController.dispose();  // Clean up progress animation
    super.dispose();
  }

  // Function to start typewriter animation for greeting
  void _startTypingGreeting() {
    String name = widget.userData.name.isNotEmpty ? widget.userData.name : 'User';
    String welcomeMessage = 'Welcome back, $name!';
    int currentIndex = 0;

    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (currentIndex < welcomeMessage.length) {
        setState(() {
          greetingText += welcomeMessage[currentIndex];
          currentIndex++;
        });
      } else {
        timer.cancel();
        _confettiController.play();  // Play confetti when greeting is done
      }
    });
  }

  Future<void> _completeIntro(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstLaunch', false);  // Mark intro as completed

      await _saveUserData(widget.userData);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            selectedCategories: widget.userData.selectedCategories ?? [],  // Navigate to HomePage
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange.shade400, Colors.deepOrange.shade700],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Floating abstract shapes with shadow
          _buildAbstractShape(top: -50, left: -50, size: 200, opacity: 0.1, right: 0),
          _buildAbstractShape(top: 100, right: -30, size: 150, opacity: 0.2),
          _buildAbstractShape(top: 300, left: 80, size: 250, opacity: 0.15, right: 0),
          _buildAbstractShape(bottom: 50, right: 50, size: 160, opacity: 0.2, top: 0.1),

          // Confetti widget
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14 / 2,  // Blast upwards
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.3,
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with glow effect, ensuring the controller is initialized before use
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

                // Greeting with fly-in animation
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

                // Circular Progress Bar
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
                      : null,  // Disable button until animations are done
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    backgroundColor: Colors.deepOrange.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Go to App', style: TextStyle(color: Colors.black)),
                      const SizedBox(width: 8),
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
