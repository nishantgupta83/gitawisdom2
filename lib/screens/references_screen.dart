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
                  // Primary Sources Section
                  _buildSectionCard(
                    context,
                    'Primary Sources',
                    Icons.book,
                    theme.colorScheme.primary,
                    [
                      {
                        'title': 'Bhagavad Gita Translations and Commentaries:',
                        'content': '',
                        'isHeader': true,
                      },
                      {
                        'title': '',
                        'content': 'Prabhupada, A.C. Bhaktivedanta Swami. (1972). Bhagavad-gita As It Is. The Bhaktivedanta Book Trust. Available online at: https://vedabase.io/en/library/bg/',
                        'isHeader': false,
                      },
                      {
                        'title': '',
                        'content': 'Easwaran, Eknath. (2007). The Bhagavad Gita. 2nd Edition. Nilgiri Press.',
                        'isHeader': false,
                      },
                    ],
                    theme,
                    isTablet,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Digital Resources Section
                  _buildSectionCard(
                    context,
                    'Digital Resources',
                    Icons.language,
                    Colors.blue,
                    [
                      {
                        'title': '',
                        'content': 'Sacred-Texts.com. The Bhagavad Gita. Internet Sacred Text Archive. Available at: https://sacred-texts.com/hin/gita/',
                        'isHeader': false,
                      },
                    ],
                    theme,
                    isTablet,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // About the Sources Section
                  _buildSectionCard(
                    context,
                    'About the Sources',
                    Icons.info_outline,
                    Colors.green,
                    [
                      {
                        'title': '',
                        'content': 'Bhagavad-gita As It Is provides word-for-word Sanskrit translations, transliterations, and detailed purports (commentaries) explaining the spiritual and practical significance of each verse.',
                        'isHeader': false,
                      },
                      {
                        'title': '',
                        'content': 'Easwaran\'s translation offers contemporary English interpretations that make ancient wisdom accessible to modern readers while maintaining philosophical authenticity.',
                        'isHeader': false,
                      },
                      {
                        'title': '',
                        'content': 'Sacred-Texts.com serves as a digital repository for multiple translations, allowing for comparative study and verification of verse interpretations.',
                        'isHeader': false,
                      },
                    ],
                    theme,
                    isTablet,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Note Section
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
                            Colors.orange.shade50.withOpacity(0.2),
                            theme.colorScheme.surface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.2),
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
                                    Icons.lightbulb_outline,
                                    color: Colors.orange.shade700,
                                    size: isTablet ? 24 : 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Note',
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
                              'All scenarios in this application apply timeless Bhagavad Gita wisdom to contemporary life situations. The ancient teachings remain relevant for addressing modern challenges in relationships, career, family life, and personal growth.',
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 15 : 14,
                                color: theme.colorScheme.onSurface,
                                height: 1.5,
                              ),
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

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    List<Map<String, dynamic>> items,
    ThemeData theme,
    bool isTablet,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      color: theme.colorScheme.surface,
      shadowColor: iconColor.withAlpha((0.12 * 255).toInt()),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: isTablet ? 24 : 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Section content
            ...items.map((item) {
              if (item['isHeader'] == true && item['content'].isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    item['title'],
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    item['content'],
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 15 : 13,
                      color: theme.colorScheme.onSurface.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                );
              }
            }).toList(),
          ],
        ),
      ),
    );
  }
}
