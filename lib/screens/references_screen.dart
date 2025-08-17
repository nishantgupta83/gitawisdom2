import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class ReferencesScreen extends StatelessWidget {
  const ReferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? screenWidth * 0.15 : 20.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image with dark overlay for dark mode
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_bg.png',
              fit: BoxFit.cover,
              color: isDark ? Colors.black.withAlpha((0.32 * 255).toInt()) : null,
              colorBlendMode: isDark ? BlendMode.darken : null,
            ),
          ),
          
          // Sticky header that stays fixed at top
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
              decoration: BoxDecoration(
                // Semi-transparent background for glassmorphism effect
                color: theme.colorScheme.surface.withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
                // Subtle border at bottom
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'REFERENCES',
                    style: GoogleFonts.poiretOne(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Underline bar
                  Container(
                    width: 80,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sources and inspirations for this app',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      letterSpacing: 0.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Scrollable content area that goes under the header
          SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 140), // Space for sticky header
              child: ListView(
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    color: theme.colorScheme.surface,
                    shadowColor: theme.colorScheme.primary.withAlpha((0.12 * 255).toInt()),
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 32.0 : 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)?.reference1 ?? 'Bhagavad-gītā As It Is by A.C. Bhaktivedanta Swami Prabhupāda',
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 16 : 15,
                              color: theme.colorScheme.onSurface,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            AppLocalizations.of(context)?.reference2 ?? 'The Bhagavad Gita translated by Eknath Easwaran',
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 16 : 15,
                              color: theme.colorScheme.onSurface,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            AppLocalizations.of(context)?.reference3 ?? 'The Bhagavad Gita translated by Barbara Stoler Miller',
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 16 : 15,
                              color: theme.colorScheme.onSurface,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Floating Back Button
          Positioned(
            top: 26,
            right: 84,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amberAccent,
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.surface,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  splashRadius: 32,
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Back',
                ),
              ),
            ),
          ),
          
          // Floating Home Button
          Positioned(
            top: 26,
            right: 24,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amberAccent,
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.surface,
                child: IconButton(
                  icon: Icon(
                    Icons.home_filled,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  splashRadius: 32,
                  onPressed: () {
                    // Use proper tab navigation to sync bottom navigation state
                    NavigationHelper.goToTab(0); // 0 = Home tab index
                  },
                  tooltip: 'Home',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
