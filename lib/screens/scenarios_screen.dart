
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ScenariosScreen extends StatefulWidget {
  final int? chapterFilter;

  const ScenariosScreen({Key? key, this.chapterFilter}) : super(key: key);

  @override
  _ScenariosScreenState createState() => _ScenariosScreenState();
}

class _ScenariosScreenState extends State<ScenariosScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _scenarios = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadScenarios();
  }

  void _loadScenarios() async {
    final scenarios = await _supabaseService.fetchScenarios(
      chapter: widget.chapterFilter,
    );
    setState(() {
      _scenarios = scenarios;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _scenarios.length,
            itemBuilder: (context, index) {
              final scenario = _scenarios[index];
              return Card(
                color: Colors.white.withOpacity(0.85),
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(scenario['title']),
                  subtitle: Text(scenario['description']),
                  onTap: () {
                    // Optionally navigate to detailed scenario view
                  },
                ),
              );
            },
          );
  }
}
