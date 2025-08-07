// lib/screens/scenarios_screen.dart

import 'package:flutter/material.dart';
import '../models/scenario.dart';
import '../services/supabase_service.dart';
import 'scenario_detail_view.dart';
import '../widgets/expandable_text.dart';

class ScenariosScreen extends StatefulWidget {
  final String? filterTag;
  const ScenariosScreen({Key? key, this.filterTag}) : super(key: key);

  @override
  State<ScenariosScreen> createState() => _ScenariosScreenState();
}

class _ScenariosScreenState extends State<ScenariosScreen> {
  final SupabaseService _service = SupabaseService();
  List<Scenario> _scenarios = [];
  String _search = '';
  String? _selectedTag;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedTag = widget.filterTag;
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    setState(() => _isLoading = true);
    try {
      final scenarios = await _service.fetchScenarios();
      setState(() => _scenarios = scenarios);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<String> get _tags {
    final tags = <String>{};
    for (final s in _scenarios) {
      if (s.tags != null) tags.addAll(s.tags!);
    }
    final sorted = tags.toList()..sort();
    return sorted;
  }


  List<Scenario> get _filtered => _scenarios.where((s) {
    final tagOk = _selectedTag == null || (s.tags?.contains(_selectedTag) ?? false);
    final textOk = _search.isEmpty || s.title.toLowerCase().contains(_search.toLowerCase());
    return tagOk && textOk;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:
        SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: TextField(
                  onChanged: (s) => setState(() => _search = s),
                  decoration: InputDecoration(
                    hintText: 'Search scenarios…',
                    hintStyle: t.textTheme.bodyMedium,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _search = ''),
                    )
                        : null,
                    filled: true,
                    fillColor: t.colorScheme.surface.withOpacity(.95),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: t.textTheme.bodyMedium,
                ),
              ),

              _tagPillsRow(
                _tags, // a List<String> of tags in this scenario list
                _selectedTag, // nullable, null for "All"
                    (tag) => setState(() => _selectedTag = tag),
              ),

              // Scenario List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) {
                    final s = _filtered[i];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(18),
                        title: Text(s.title, style: t.textTheme.titleMedium),
                        subtitle: s.description.isNotEmpty
                            ? Text(s.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.textTheme.bodyMedium)
                            : null,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ScenarioDetailView(scenario: s)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
    );

  }

  Widget _tagPillsRow(List<String> tags, String? selectedTag, ValueChanged<String?> onTapTag) {
    final theme = Theme.of(context);
    const int showCount = 3;
    final totalCount = tags.length;

    // Always start with ALL
    final pills = <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text('All', style: theme.textTheme.labelMedium),
          selected: selectedTag == null,
          onSelected: (_) => onTapTag(null),
        ),
      ),
    ];

    // Then up to 3 tags
    for (var i = 0; i < totalCount && i < showCount; ++i) {
      final tag = tags[i];
      pills.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text('#$tag', style: theme.textTheme.labelMedium),
            selected: selectedTag == tag,
            onSelected: (_) => onTapTag(tag),
          ),
        ),
      );
    }
    // "+N" chip for more tags
    if (totalCount > showCount) {
      final moreCount = totalCount - showCount;
      pills.add(
        ActionChip(
          label: Text('+$moreCount', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimary)),
          backgroundColor: theme.colorScheme.primary,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: theme.colorScheme.surface,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
              builder: (_) => ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
                children: tags.map((tag) => ListTile(
                  title: Text('#$tag', style: theme.textTheme.bodyMedium),
                  selected: selectedTag == tag,
                  onTap: () {
                    Navigator.pop(context);
                    onTapTag(tag);
                  },
                )).toList(),
              ),
            );
          },
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(children: pills),
    );
  }

}


