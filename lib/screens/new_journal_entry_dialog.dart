// Journal Entry Dialog with enhanced UX improvements
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/journal_entry.dart';
import '../l10n/app_localizations.dart';

typedef EntryCallback = Future<void> Function(JournalEntry e);

class NewJournalEntryDialog extends StatefulWidget {
  final EntryCallback onSave;
  final int? scenarioId;
  final String? scenarioTitle;
  final String? initialCategory;
  
  const NewJournalEntryDialog({
    Key? key, 
    required this.onSave,
    this.scenarioId,
    this.scenarioTitle,
    this.initialCategory,
  }) : super(key: key);

  @override
  _NewJournalEntryDialogState createState() => _NewJournalEntryDialogState();
}

class _NewJournalEntryDialogState extends State<NewJournalEntryDialog> with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  int _rating = 3; // Default rating of 3 stars for better UX
  bool _saving = false;
  late String _selectedCategoryKey;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  static const List<String> _categoryKeys = [
    'categoryGeneral',
    'categoryPersonalGrowth', 
    'categoryMeditation',
    'categoryDailyReflection',
    'categoryScenarioWisdom',
    'categoryChapterInsights',
    'categoryDharmaInsights',
    'categoryKarmaReflections',
    'categoryMeditationExperiences',
    'categoryDetachmentPractice',
  ];

  @override
  void initState() {
    super.initState();
    // Set initial category (from scenario context or default)
    _selectedCategoryKey = widget.initialCategory ?? 'categoryGeneral';

    // Pre-fill journal prompt if coming from scenario
    if (widget.scenarioTitle != null) {
      _ctrl.text = 'Reflecting on "${widget.scenarioTitle}":\n\nHow does this scenario relate to my life? What wisdom can I apply from this situation?\n\n';
      // Move cursor to end for user to continue writing
      _ctrl.selection = TextSelection.fromPosition(TextPosition(offset: _ctrl.text.length));
    }

    // Initialize pulse animation for Save button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.stop();
    _pulseController.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _doSave() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _saving) return;

    // Rating is now defaulted to 3, so no validation needed
    // if (_rating == 0) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectRating ?? 'Please select a rating')),
    //   );
    //   return;
    // }

    setState(() => _saving = true);

    try {
      final entry = JournalEntry.create(
        reflection: text,
        rating: _rating,
        scenarioId: widget.scenarioId,
        category: _getCategoryValue(AppLocalizations.of(context)!, _selectedCategoryKey),
      );

      await widget.onSave(entry);
      if (mounted) {
        Navigator.of(context).pop();
        // Show success toast with "View Entries" action
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✓ Journal entry saved!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'View Entries',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to journal tab (index 3)
                if (mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save entry: $e')),
        );
      }
    }
  }
  
  String _getCategoryValue(AppLocalizations localizations, String categoryKey) {
    switch (categoryKey) {
      case 'categoryGeneral':
        return localizations.categoryGeneral;
      case 'categoryPersonalGrowth':
        return localizations.categoryPersonalGrowth;
      case 'categoryMeditation':
        return localizations.categoryMeditation;
      case 'categoryDailyReflection':
        return localizations.categoryDailyReflection;
      case 'categoryScenarioWisdom':
        return localizations.categoryScenarioWisdom;
      case 'categoryChapterInsights':
        return localizations.categoryChapterInsights;
      case 'categoryDharmaInsights':
        return 'Dharma Insights';
      case 'categoryKarmaReflections':
        return 'Karma Reflections';
      case 'categoryMeditationExperiences':
        return 'Meditation Experiences';
      case 'categoryDetachmentPractice':
        return 'Detachment Practice';
      default:
        return localizations.categoryGeneral;
    }
  }

  String _getCategoryHint(String categoryKey) {
    switch (categoryKey) {
      case 'categoryDharmaInsights':
        return 'Reflections on righteous duty and moral choices';
      case 'categoryKarmaReflections':
        return 'Understanding action, consequence, and detachment';
      case 'categoryMeditationExperiences':
        return 'Spiritual practices, peace, and inner stillness';
      case 'categoryDetachmentPractice':
        return 'Letting go of outcomes and finding equanimity';
      case 'categoryScenarioWisdom':
        return 'Applying Gita teachings to life situations';
      case 'categoryChapterInsights':
        return 'Wisdom gained from specific Gita chapters';
      case 'categoryPersonalGrowth':
        return 'Self-development and character building';
      case 'categoryDailyReflection':
        return 'Daily thoughts and spiritual observations';
      default:
        return 'General thoughts and reflections';
    }
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Feeling Challenged';
      case 2:
        return 'Somewhat Neutral';
      case 3:
        return 'Feeling Centered';
      case 4:
        return 'Feeling Grateful';
      case 5:
        return 'Truly Blessed';
      default:
        return 'No rating';
    }
  }

  String _getRatingEmoji(int rating) {
    switch (rating) {
      case 1:
        return '😞';
      case 2:
        return '😐';
      case 3:
        return '🙂';
      case 4:
        return '😃';
      case 5:
        return '🤩';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext c) {
    final theme = Theme.of(c);
    final localizations = AppLocalizations.of(c)!;
    final screenHeight = MediaQuery.of(c).size.height;
    final maxDialogHeight = screenHeight * 0.8; // Use maximum 80% of screen height
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFFF3E5F5), // Lavender tint (light purple)
              Color(0xFFE1BEE7), // Slightly deeper lavender
              Colors.white,
            ],
            center: Alignment.topCenter,
            radius: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF9C27B0).withValues(alpha: 0.15),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxDialogHeight,
            maxWidth: 400, // Reasonable max width for tablets
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Title
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                localizations.newJournalEntry,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _ctrl,
                      decoration: InputDecoration(labelText: localizations.yourReflection),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),

                    // Category label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizations.category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Category Capsule Buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'categoryPersonalGrowth',
                        'categoryDailyReflection',
                        'categoryMeditation',
                        'categoryGeneral',
                      ].map((categoryKey) {
                        final isSelected = _selectedCategoryKey == categoryKey;
                        final categoryValue = _getCategoryValue(localizations, categoryKey);

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _saving ? null : () {
                              setState(() => _selectedCategoryKey = categoryKey);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                categoryValue,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Rating Section with Emojis
                    Text(
                      localizations.rating,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Emoji Hints (Tappable)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final rating = i + 1;
                        final isSelected = _rating == rating;
                        return GestureDetector(
                          onTap: _saving ? null : () {
                            HapticFeedback.mediumImpact();
                            setState(() => _rating = rating);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                                : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getRatingEmoji(rating),
                              style: TextStyle(
                                fontSize: isSelected ? 32 : 28,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),

                    // Star Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        return IconButton(
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                          icon: Icon(
                            i < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 28,
                          ),
                          onPressed: _saving ? null : () {
                            HapticFeedback.mediumImpact();
                            setState(() => _rating = i + 1);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 8),

                    // Dynamic Rating Label
                    Text(
                      _getRatingLabel(_rating),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16), // Extra spacing to prevent bottom overflow
                  ],
                ),
              ),
            ),
            
            // Actions - Side by Side with Gradient Save Button
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Row(
                children: [
                  // Cancel Button (Outlined)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        localizations.cancel,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Save Button (Gradient with Pulse Animation)
                  Expanded(
                    child: ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF9C27B0), // Purple
                              Color(0xFFBA68C8), // Light Purple
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF9C27B0).withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _saving ? null : _doSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  localizations.save,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
