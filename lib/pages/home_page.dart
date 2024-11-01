import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled5/pages/categories_page.dart';
import 'package:untitled5/pages/settings_page.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibration/vibration.dart';
import 'dart:io';
import 'dart:typed_data';

class HomePage extends StatefulWidget {
  final List<String> selectedCategories;

  const HomePage({super.key, required this.selectedCategories});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String quote = "Loading your Leo quote...";
  List<String> categoryQuotes = [];
  bool isFavorite = false; // Track favorite status
  bool _isSharing = false; // Track sharing state
  final DatabaseReference quotesRef = FirebaseDatabase.instance.ref('quotes');
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  void _fetchQuote() async {
    try {
      DatabaseEvent event = await quotesRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        List<dynamic> allQuotes = snapshot.value as List<dynamic>;
        List<String> tempQuotes = [];

        for (var category in widget.selectedCategories) {
          for (var quoteObj in allQuotes) {
            if (quoteObj['category'] == category) {
              tempQuotes.addAll(List<String>.from(quoteObj['text'].values));
            }
          }
        }

        setState(() {
          categoryQuotes = tempQuotes..shuffle();
          quote = categoryQuotes.isNotEmpty
              ? categoryQuotes[0]
              : "No quotes available.";
        });
      }
    } catch (e) {
      setState(() {
        quote = "Error loading quotes. Please try again later.";
      });
    }
  }

  Widget _buildScreenshotContent(String quote) {
    return Container(
      color: Colors.orange.shade50,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                quote,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/playstore_icon.png',
                  height: 30,
                ),
                const SizedBox(width: 5),
                Text(
                  'Leo Quotes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareQuoteAsImage() async {
    setState(() {
      _isSharing = true; // Set sharing state to true
    });

    try {
      final Uint8List image = await screenshotController.captureFromWidget(
        _buildScreenshotContent(quote),
      );

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/quote_image.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      XFile imageXFile = XFile(imagePath);

      await Share.shareXFiles(
        [imageXFile],
        text: 'Download the app: https://play.google.com/store/apps/details?id=com.nigamman.leoquotes',
      );

      // Optional: Show success feedback
    } catch (e) {
      print('Error sharing the image: $e');
      _showSnackBar('Failed to share the quote. Please try again.');
    } finally {
      setState(() {
        _isSharing = false; // Reset sharing state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text(
          'Leo Quotes',
          style: GoogleFonts.lobster(color: Colors.white, fontSize: 28),
        ),
        backgroundColor: Colors.deepOrange.shade700,
        elevation: 0,
      ),
      body: Screenshot(
        controller: screenshotController,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  quote,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (_isSharing) CircularProgressIndicator(), // Show loading indicator
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrangeAccent,
        onPressed: () async {
          if (await Vibration.hasVibrator() != null) {
            Vibration.vibrate(duration: 50);
          }
          setState(() {
            isFavorite = false; // Reset favorite status
          });
          _fetchQuote(); // Refresh the quotes
        },
        child: const Icon(Icons.refresh), // Central floating button
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 0.0,
        clipBehavior: Clip.antiAlias,
        color: Colors.deepOrange.shade300,
        child: SafeArea(
          child: SizedBox(
            height: 60, // Adjust height as necessary
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildNavItem(
                    icon: Image.asset('assets/icons/widget_icon.png', height: 44),
                    onPressed: () async {
                      if (await Vibration.hasVibrator() != null) {
                        Vibration.vibrate(duration: 50);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoriesPage(),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    icon: Image.asset('assets/icons/send_icon.png', height: 36),
                    onPressed: () async {
                      if (await Vibration.hasVibrator() != null) {
                        Vibration.vibrate(duration: 50);
                      }
                      _shareQuoteAsImage(); // Share the screenshot
                    },
                  ),
                ),
                const SizedBox(width: 40), // Space for the FAB
                Expanded(
                  child: _buildNavItem(
                    icon: isFavorite
                        ? Image.asset('assets/icons/favorite_icon.png', height: 30)
                        : Image.asset('assets/icons/favorite_filled.png', height: 30),
                    onPressed: () {
                      setState(() {
                        if (!isFavorite) {
                          isFavorite = true;
                          _showSnackBar('Thanks for liking the quote!'); // Show Snackbar only when favorited
                        }
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    icon: Image.asset('assets/icons/settings_icon.png', height: 30),
                    onPressed: () async {
                      if (await Vibration.hasVibrator() != null) {
                        Vibration.vibrate(duration: 50);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16), // Spacing from the edges
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildNavItem({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: icon,
      iconSize: 30, // Adjust the size of the icon as needed
      onPressed: onPressed,
    );
  }
}
