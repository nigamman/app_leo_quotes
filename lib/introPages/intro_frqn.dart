import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled5/introPages/intro_reminder.dart';
import 'package:untitled5/models/user_data.dart';

class IntroPageFrequency extends StatefulWidget {
  final UserData userData;

  const IntroPageFrequency({super.key, required this.userData});

  @override
  _IntroPageFrequencyState createState() => _IntroPageFrequencyState();
}

class _IntroPageFrequencyState extends State<IntroPageFrequency> {
  String _selectedFrequency = '';

  Future<void> _storeFrequency(String selectedFrequency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFrequency', selectedFrequency); // Save the frequency
  }

// Call this method when the user selects a frequency
  void _onFrequencySelected(String frequency) {
    setState(() {
      _selectedFrequency = frequency;
    });
    _storeFrequency(frequency);
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
          _buildAbstractShape(top: -50, left: -50, size: 200, opacity: 0.1),
          _buildAbstractShape(top: 100, right: -30, size: 150, opacity: 0.2),
          _buildAbstractShape(top: 300, left: 80, size: 250, opacity: 0.15),
          _buildAbstractShape(bottom: 50, right: 50, size: 160, opacity: 0.2,top: 0),

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
                      'assets/images/gen.ico', // Replace with your logo
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title with animation
                FadeIn(
                  child: Text(
                    'Select Frequency',
                    style: GoogleFonts.lobster(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                // Explanation of frequency
                FadeInUp(
                  child: Text(
                    'How often would you like to receive motivational quotes? '
                        'Select how frequently the quotes should change throughout the day.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                // Progress indicator
                FadeInUp(
                  child: LinearProgressIndicator(
                    value: 0.66, // Example progress, page 4 of 6
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 30),

                // Frequency Options with custom styling
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFrequencyCard('Every 6 hours', Colors.orange),
                      _buildFrequencyCard('Every 12 hours', Colors.green),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Motivational quote
                FadeInUp(
                  child: Text(
                    '"Consistency is key!"',
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
                    onPressed: () {
                      if (_selectedFrequency.isNotEmpty) {
                        widget.userData.frequency = _selectedFrequency;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IntroPageReminder(userData: widget.userData),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a frequency.')),
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

  // Custom frequency card
  Widget _buildFrequencyCard(String title, Color color) {
    return GestureDetector(
      onTap: () {
        _onFrequencySelected(title); // Call this to update the state and store frequency
      },
      // onTap: () {
      //   setState(() {
      //     _selectedFrequency = title;
      //   });
      // },
      child: Card(
        elevation: _selectedFrequency == title ? 8 : 2,
        color: _selectedFrequency == title ? color : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _selectedFrequency == title ? Icons.check_circle : Icons.circle,
                color: _selectedFrequency == title ? Colors.white : Colors.black,
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: _selectedFrequency == title ? Colors.white : Colors.deepOrange,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Abstract background shape method
  Widget _buildAbstractShape({
    required double top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
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