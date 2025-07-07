
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
  url: 'https://wlfwdtdtiedlcczfoslt.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU',
  );
  runApp(WisdomGuideApp());
}

class WisdomGuideApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wisdom Guide',
      theme: ThemeData(
        fontFamily: 'Serif',
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  
  import 'screens/chapters_screen.dart';
import 'screens/scenarios_screen.dart';

  static final List<Widget> _pages = <Widget>[
    PlaceholderScreen(title: 'Home'),
   ChaptersScreen(),
    ScenariosScreen(),
    PlaceholderScreen(title: 'Journal'),
    PlaceholderScreen(title: 'More'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/scroll_background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: _pages.elementAt(_selectedIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Chapters'),
              BottomNavigationBarItem(icon: Icon(Icons.filter_list), label: 'Scenarios'),
              BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Journal'),
              BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.brown,
            onTap: _onItemTapped,
          ),
        ),
      ],
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
