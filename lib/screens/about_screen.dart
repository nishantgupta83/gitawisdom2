import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        // use your theme surface so it shows up as a light card
        backgroundColor: theme.colorScheme.surface,
        title: const Text('About'),
        centerTitle: true,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB (10,100,10,10),
        child: Card(
          // explicitly set to your card color
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Gitawisdom v1.0.0\n\n'
                  'A bite-size guide to the Bhagavad Gita, offering chapters, scenarios, '
                  'and reflections—now with custom themes, language support, and more.'
                  ' \n \n \n '
                  ' You have the right to perform your actions, but you are not entitled to the fruits of action.* - Bhagavad Gita 2.47'
                  ' \n \n \n '
                   'Made with ❤️ for spiritual seekers everywhere'
              ,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }
}
