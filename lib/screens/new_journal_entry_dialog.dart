import 'package:flutter/material.dart';
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

class _NewJournalEntryDialogState extends State<NewJournalEntryDialog> {
  final _ctrl = TextEditingController();
  int _rating = 3; // Default rating of 3 stars for better UX
  bool _saving = false;
  late String _selectedCategoryKey;
  
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
      if (mounted) Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext c) {
    final theme = Theme.of(c);
    final localizations = AppLocalizations.of(c)!;
    final screenHeight = MediaQuery.of(c).size.height;
    final maxDialogHeight = screenHeight * 0.8; // Use maximum 80% of screen height
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                      : theme.colorScheme.outline.withOpacity(0.3),
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
                    
                    // Rating Stars with better layout
                    Text(
                      '${localizations.rating} (${_rating}/5)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 4, // Add spacing between stars
                        children: List.generate(5, (i) {
                          return IconButton(
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            icon: Icon(
                              i < _rating ? Icons.star : Icons.star_border,
                              color: Colors.amber, // More recognizable color
                              size: 28,
                            ),
                            onPressed: _saving ? null : () => setState(() => _rating = i + 1),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16), // Extra spacing to prevent bottom overflow
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28), // Extra bottom padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(c),
                    child: Text(localizations.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saving ? null : _doSave,
                    child: _saving
                        ? const SizedBox(
                            height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(localizations.save),
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
