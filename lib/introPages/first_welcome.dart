import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

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
          // Abstract shapes
          // Abstract shapes
          _buildAbstractShape(top: -50, right: -50, size: 200, opacity: 0.1),
          _buildAbstractShape(top: 100, right: -30, size: 150, opacity: 0.2),
          _buildAbstractShape(top: 300, right: 80, size: 250, opacity: 0.15),
          _buildAbstractShape(top:100, right: 40, size: 180, opacity: 0.25),
          _buildAbstractShape(top: 200, right: 20, size: 100, opacity: 0.3),
          // Main content with top padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Animated Logo with custom icon
                ZoomIn(
                  child: Hero(
                    tag: 'app-logo',
                    child: Image.asset(
                      'assets/images/gen.ico', // Replace with your app's logo path
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Welcome Text with animation
                FadeIn(
                  child: Text(
                    'Welcome to Leo Quotes!',
                    style: GoogleFonts.lobster(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                // Features Section with New Font and Animations
                Expanded(
                  child: FadeInUp(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFeatureCard(
                          icon: Icons.category,
                          title: 'Personalized Quote Categories',
                          description: 'Choose categories that fit your mood and personality.',
                          context: context,
                        ),
                        const SizedBox(height: 20),
                        _buildFeatureCard(
                          icon: Icons.notifications_active,
                          title: 'Daily or Hourly Notifications',
                          description: 'Get inspirational notifications throughout the day.',
                          context: context,
                        ),
                        const SizedBox(height: 20),
                        _buildFeatureCard(
                          icon: Icons.widgets,
                          title: 'Quick Access Widgets',
                          description: 'Add widgets to access your favorite quotes instantly.',
                          context: context,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Get Started Button with ripple effect
                ElasticIn(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/namePage');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepOrange,
                      shadowColor: Colors.black,
                      elevation: 10,
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 22),
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

  // Method to build abstract shapes
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

  // Feature Card builder with new font and text animations
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required BuildContext context,
  }) {
    return FadeInUp(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: Icon(icon, size: 40, color: Colors.deepOrange),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          subtitle: Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}