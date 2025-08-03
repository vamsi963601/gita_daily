import 'dart:ui'; // Required for the ImageFilter.blur effect!

import 'package:flutter/material.dart';
import 'package:gita_daily/models/gita_models.dart';
import 'package:gita_daily/service/gita_api_service.dart';
import 'package:gita_daily/service/streak_manager.dart';

// --- IMPORTS for Rich UI ---
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'package:flutter_spinkit/flutter_spinkit.dart'; // For the loading animation
import 'package:animate_do/animate_do.dart'; // For entry animations

class DailySlokaScreen extends StatefulWidget {
  const DailySlokaScreen({super.key});

  @override
  State<DailySlokaScreen> createState() => _DailySlokaScreenState();
}

class _DailySlokaScreenState extends State<DailySlokaScreen> {
  final GitaApiService _apiService = GitaApiService();
  final StreakManager _streakManager = StreakManager();

  Verse? _verse;
  int _streakCount = 0;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDailyData();
  }

  Future<void> _loadDailyData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _streakManager.updateStreak();
      final streak = await _streakManager.getStreakCount();

      final dayOfYear =
          DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
      final chapter = (dayOfYear % 18) + 1;
      final verseNum = (dayOfYear % 25) + 1;

      final fetchedVerse = await _apiService.getVerse(chapter, verseNum);
      if (fetchedVerse == null) throw Exception("Verse not found for today.");

      if (mounted) {
        setState(() {
          _streakCount = streak;
          _verse = fetchedVerse;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              "Failed to load verse. Please check your connection and try again.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildBodyContent(),
        ],
      ),
    );
  }

  /// Creates a layered background with a gradient and a subtle pattern image.
  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade200,
            Colors.deepOrange.shade400,
          ],
        ),
        image: DecorationImage(
          image: const AssetImage('assets/images/background.png'), // Your background image
          fit: BoxFit.cover,
          // Adjust opacity to your liking, 0.1 to 0.2 is usually good.
          opacity: 0.7,
        ),
      ),
    );
  }

  /// Builds the body content based on the current state (loading, error, or success).
  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(
        child: SpinKitFadingCircle(
          color: Colors.white,
          size: 50.0,
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadDailyData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepOrange,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: _buildVerseCard(
                title: 'श्लोक (Sloka)',
                text: _verse?.text ?? "",
                font: GoogleFonts.laila(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade900,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: _buildVerseCard(
                title: 'Translation',
                text: _verse?.meaning ?? "",
                font: GoogleFonts.tinos(
                  fontSize: 20,
                  color: Colors.black.withOpacity(0.85),
                  height: 1.5,
                ),
              ),
            ),
            const Spacer(),
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 200),
              child: _buildStreakCounter(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// A reusable widget to create the styled cards for content.
  /// This version uses a BackdropFilter to create a "frosted glass" effect for sharp text.
  Widget _buildVerseCard({required String title, required String text, required TextStyle font}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const Divider(height: 20, color: Colors.white70),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: font.copyWith(
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black.withOpacity(0.25),
                        offset: const Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The redesigned streak counter widget.
  Widget _buildStreakCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.whatshot, color: Colors.deepOrange.shade600, size: 28),
          const SizedBox(width: 12),
          Text(
            '$_streakCount Day Streak!',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade900,
            ),
          ),
        ],
      ),
    );
  }
}