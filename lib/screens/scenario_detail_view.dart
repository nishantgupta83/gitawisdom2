import 'package:flutter/material.dart';

import '../models/scenario.dart';
import '../screens/scenarios_screen.dart';

class ScenarioDetailView extends StatefulWidget {
  final Scenario scenario;

  const ScenarioDetailView({Key? key, required this.scenario}) : super(key: key);

  @override
  _ScenarioDetailViewState createState() => _ScenarioDetailViewState();
}

class _ScenarioDetailViewState extends State<ScenarioDetailView> {
  final ScrollController _ctrl = ScrollController();
  final GlobalKey _actionsKey = GlobalKey();
  bool _showActions = false;

  void _revealActions() {
    setState(() => _showActions = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(_actionsKey.currentContext!, duration: const Duration(milliseconds: 350));
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: !_showActions
          ? FloatingActionButton.extended(
        heroTag: 'fab',
        onPressed: _revealActions,
        backgroundColor: t.colorScheme.primary,
        label: const Text('Show Wisdom'),
        icon: const Icon(Icons.brightness_7_outlined),
      )
        : null,
      body: SafeArea(
        child: Stack(
          children: [
            // Floating navigation buttons
            Positioned(
              top: 26,
              right: 84,
              child: _glowingNavButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: 26,
              right: 24,
              child: _glowingNavButton(
                icon: Icons.home,
                onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
              ),
            ),

            // Scroll content
            SingleChildScrollView(
              controller: _ctrl,
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _titleHeader(t),
                  _card('Description', widget.scenario.description, t),
                  _buildHeartSection(t),
                  _buildDutySection(t),
                  if (widget.scenario.tags?.isNotEmpty ?? false) _tagCard(t),
                  _card('Gita Wisdom', widget.scenario.gitaWisdom, t),
                  if (_showActions) _actionStepsCard(t),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // helper widgets (compact) ...
  Widget _titleHeader(ThemeData t) => Text(widget.scenario.title,
      style: t.textTheme.headlineMedium
  );

  Widget _card(String title, String body, ThemeData t) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
            style: t.textTheme.titleMedium
          ),
          const SizedBox(height: 10),
          Text(body,
            style: t.textTheme.bodyMedium
          ),
        ]),
      ),
    ),
  );

  Widget _buildHeartSection(ThemeData t) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.cloud, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Heart Says',
                      style: t.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(widget.scenario.heartResponse,
                      style: t.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDutySection(ThemeData t) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.balance, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Duty Says',
                      style: t.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(widget.scenario.dutyResponse,
                      style: t.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagCard(ThemeData t) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: widget.scenario.tags!
            .map((tag) => ActionChip(
              label: Text(tag),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScenariosScreen(filterTag: tag),
                  ),
                );
              },
            ))
            .toList(),
      ),
    ),
  );

  Widget _actionStepsCard(ThemeData t) => Container(
    key: _actionsKey,
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wisdom Steps',
                style: t.textTheme.titleMedium
                ),
            const SizedBox(height: 10),
            ...?widget.scenario.actionSteps?.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: t.textTheme.bodyMedium),
                  Expanded(
                    child: Text(s, style: t.textTheme.bodyMedium),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    ),
  );

  // Same glowing nav button as home screen
  Widget _glowingNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withAlpha(40),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white.withAlpha((0.8 * 255).toInt()),
          child: IconButton(
            splashRadius: 28,
            icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
            onPressed: onTap,
          ),
        ),
      );
}