// lib/services/share_card_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/verse.dart';
import '../models/scenario.dart';

/// Card design theme (simplified to use one default theme)
enum ShareCardTheme {
  minimalist,
}

/// Service for creating and sharing beautiful verse cards
/// Generates simple, elegant quote images for social sharing
class ShareCardService {
  static final ShareCardService _instance = ShareCardService._internal();
  factory ShareCardService() => _instance;
  ShareCardService._internal();

  static ShareCardService get instance => _instance;

  /// Generate a verse card without sharing (for preview)
  Future<Uint8List> generateVerseCard(Verse verse, ShareCardTheme theme) async {
    return _generateVerseCard(verse, theme);
  }

  /// Generate a scenario card without sharing (for preview)
  Future<Uint8List> generateScenarioCard(Scenario scenario, ShareCardTheme theme) async {
    return _generateScenarioCard(scenario, theme);
  }

  /// Generate and share a verse card
  Future<bool> shareVerseCard({
    required Verse verse,
  }) async {
    try {
      final cardImage = await _generateVerseCard(verse, ShareCardTheme.minimalist);
      final imagePath = await _saveCardToTemp(cardImage, 'verse_card');

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: '''Bhagavad Gita Chapter ${verse.chapterId}, Verse ${verse.verseId}

${verse.description}

🌿 Get GitaWisdom App:
📱 https://play.google.com/store/apps/details?id=com.hub4apps.gitawisdom''',
        subject: 'Wisdom from Bhagavad Gita',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 200, 200),
      );

      return true;
    } catch (e) {
      debugPrint('❌ Error sharing verse card: $e');
      return false;
    }
  }

  /// Generate and share a scenario wisdom card
  Future<bool> shareScenarioCard({
    required Scenario scenario,
  }) async {
    try {
      final cardImage = await _generateScenarioCard(scenario, ShareCardTheme.minimalist);
      final imagePath = await _saveCardToTemp(cardImage, 'scenario_card');

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: '''${scenario.title}

${scenario.description}

🌿 Get GitaWisdom - Ancient wisdom for modern life:
📱 https://play.google.com/store/apps/details?id=com.hub4apps.gitawisdom''',
        subject: 'Gita Wisdom for Daily Life',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 200, 200),
      );

      return true;
    } catch (e) {
      debugPrint('❌ Error sharing scenario card: $e');
      return false;
    }
  }

  /// Generate verse card image
  Future<Uint8List> _generateVerseCard(Verse verse, ShareCardTheme theme) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1080, 1920); // Instagram story size
    
    // Draw background
    await _drawCardBackground(canvas, size, theme);
    
    // Draw verse content
    _drawVerseContent(canvas, size, verse, theme);
    
    // Draw branding
    _drawBranding(canvas, size);
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  /// Generate scenario card image
  Future<Uint8List> _generateScenarioCard(Scenario scenario, ShareCardTheme theme) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1080, 1080); // Instagram post size
    
    // Draw background
    await _drawCardBackground(canvas, size, theme);
    
    // Draw scenario content
    _drawScenarioContent(canvas, size, scenario, theme);
    
    // Draw branding
    _drawBranding(canvas, size);
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  /// Draw simple minimalist background
  Future<void> _drawCardBackground(Canvas canvas, Size size, ShareCardTheme theme) async {
    final paint = Paint();

    // Simple minimalist gradient
    paint.shader = ui.Gradient.linear(
      Offset.zero,
      Offset(size.width, size.height),
      [
        const Color(0xFFFAFAFA),
        const Color(0xFFF5F5F5),
      ],
    );

    canvas.drawRect(Offset.zero & size, paint);
  }

  /// Draw verse content on card
  void _drawVerseContent(Canvas canvas, Size size, Verse verse, ShareCardTheme theme) {
    final textColor = _getTextColor(theme);
    final accentColor = _getAccentColor(theme);
    
    // Draw chapter and verse reference
    final referencePainter = TextPainter(
      text: TextSpan(
        text: 'Bhagavad Gita ${verse.chapterId}.${verse.verseId}',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w300,
          color: accentColor,
          letterSpacing: 2.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    referencePainter.layout(maxWidth: size.width - 120);
    referencePainter.paint(canvas, Offset(60, size.height * 0.15));
    
    // Draw verse text
    final versePainter = TextPainter(
      text: TextSpan(
        text: verse.description,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: textColor,
          height: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    versePainter.layout(maxWidth: size.width - 120);
    
    final verseY = (size.height - versePainter.height) / 2;
    versePainter.paint(canvas, Offset(60, verseY));
  }

  /// Draw scenario content on card
  void _drawScenarioContent(Canvas canvas, Size size, Scenario scenario, ShareCardTheme theme) {
    final textColor = _getTextColor(theme);
    final accentColor = _getAccentColor(theme);
    
    // Draw title
    final titlePainter = TextPainter(
      text: TextSpan(
        text: scenario.title,
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: textColor,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    titlePainter.layout(maxWidth: size.width - 120);
    titlePainter.paint(canvas, Offset(60, size.height * 0.2));
    
    // Draw description
    final descPainter = TextPainter(
      text: TextSpan(
        text: scenario.description,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: textColor,
          height: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    descPainter.layout(maxWidth: size.width - 120);
    
    final descY = titlePainter.height + size.height * 0.25;
    descPainter.paint(canvas, Offset(60, descY));
    
    // Draw category badge
    final categoryPainter = TextPainter(
      text: TextSpan(
        text: '🧭 DAILY WISDOM',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: accentColor,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    categoryPainter.layout();
    categoryPainter.paint(
      canvas,
      Offset(
        (size.width - categoryPainter.width) / 2,
        size.height * 0.85,
      ),
    );
  }

  /// Draw app branding
  void _drawBranding(Canvas canvas, Size size) {
    final brandPainter = TextPainter(
      text: const TextSpan(
        text: 'GitaWisdom',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    brandPainter.layout();
    brandPainter.paint(
      canvas,
      Offset(
        size.width - brandPainter.width - 40,
        size.height - brandPainter.height - 40,
      ),
    );
  }

  /// Get text color for minimalist theme
  Color _getTextColor(ShareCardTheme theme) {
    return const Color(0xFF263238);
  }

  /// Get accent color for minimalist theme
  Color _getAccentColor(ShareCardTheme theme) {
    return const Color(0xFFFF8A65);
  }

  /// Save card to temporary directory
  Future<String> _saveCardToTemp(Uint8List imageBytes, String prefix) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/${prefix}_$timestamp.png';
    
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);
    
    return filePath;
  }


}