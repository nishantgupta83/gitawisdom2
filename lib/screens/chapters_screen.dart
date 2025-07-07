
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ChaptersScreen extends StatefulWidget {
  @override
  _ChaptersScreenState createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _chapters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  void _loadChapters() async {
    final chapters = await _supabaseService.fetchChapters();
    setState(() {
      _chapters = chapters;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _chapters.length,
            itemBuilder: (context, index) {
              final chapter = _chapters[index];
              return Card(
                color: Colors.white.withOpacity(0.8),
                elevation: 3,
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text('Chapter ${chapter['number']}: ${chapter['title']}'),
                  subtitle: Text(chapter['subtitle'] ?? ''),
                  onTap: () {
                    // Navigate to chapter detail or scenarios
                  },
                ),
              );
            },
          );
  }
}
