import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../core/navigation/navigation_service.dart';
import '../widgets/app_background.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? screenWidth * 0.1 : 20.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Unified gradient background
          AppBackground(isDark: isDark),

          // Sticky header that stays fixed at top
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
              decoration: BoxDecoration(
                // Semi-transparent background for glassmorphism effect
                color: theme.colorScheme.surface.withValues(alpha: 0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
                // Subtle border at bottom
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'ABOUT GITAWISDOM',
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
                          theme.colorScheme.primary.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ancient wisdom for modern life',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                  // Made with love section
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    color: theme.colorScheme.surface,
                    shadowColor: theme.colorScheme.primary.withAlpha((0.15 * 255).toInt()),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                            theme.colorScheme.surface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: isTablet ? 48 : 40,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)?.madeWithLove ?? 'Made with ❤️ for spiritual seekers everywhere',
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Main content card with enhanced design
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    color: theme.colorScheme.surface,
                    shadowColor: theme.colorScheme.primary.withAlpha((0.12 * 255).toInt()),
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary.withValues(alpha: 0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.auto_stories,
                                  color: Colors.white,
                                  size: isTablet ? 24 : 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)?.aboutGitaWisdom ?? 'About GitaWisdom',
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 22 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          Text(
                            AppLocalizations.of(context)?.aboutDescription ?? 'GitaWisdom brings timeless wisdom to modern life. Navigate daily challenges with timeless teachings from the Bhagavad Gita.',
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 16 : 15,
                              color: theme.colorScheme.onSurface,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Container(
                            padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                                  theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.format_quote,
                                  color: theme.colorScheme.primary,
                                  size: isTablet ? 32 : 28,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  AppLocalizations.of(context)?.gitaQuote ?? '"You have a right to perform your prescribed duty, but never to the fruits of action."',
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 16 : 14,
                                    fontStyle: FontStyle.italic,
                                    height: 1.5,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '- Bhagavad Gita 2.47',
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 14 : 12,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Scenario Disclaimer Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    color: theme.colorScheme.surface,
                    shadowColor: Colors.orange.withAlpha((0.15 * 255).toInt()),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade50.withValues(alpha: 0.3),
                            theme.colorScheme.surface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.info_outline,
                                    color: Colors.orange.shade700,
                                    size: isTablet ? 24 : 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Important Note',
                                    style: GoogleFonts.poppins(
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'These scenarios are NOT based on:',
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildDisclaimerItem(
                              '• Specific Research Studies',
                              'Not from particular academic papers',
                              theme,
                              isTablet,
                            ),
                            const SizedBox(height: 8),
                            _buildDisclaimerItem(
                              '• Survey Data',
                              'Not from user surveys or interviews',
                              theme,
                              isTablet,
                            ),
                            const SizedBox(height: 8),
                            _buildDisclaimerItem(
                              '• Clinical Case Studies',
                              'Not from therapy or counseling cases',
                              theme,
                              isTablet,
                            ),
                          ],
                        ),
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
                    NavigationService.instance.goToTab(0); // 0 = Home tab index
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

  Widget _buildDisclaimerItem(String title, String subtitle, ThemeData theme, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: isTablet ? 15 : 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 13 : 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}