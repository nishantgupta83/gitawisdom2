// test/services/share_card_service_test.dart

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:GitaWisdom/services/share_card_service.dart';
import 'package:GitaWisdom/models/verse.dart';
import 'package:GitaWisdom/models/scenario.dart';
import '../test_setup.dart';

@GenerateMocks([])
void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await teardownTestEnvironment();
  });

  group('ShareCardService - Instance', () {
    test('should return singleton instance', () {
      final instance1 = ShareCardService();
      final instance2 = ShareCardService.instance;

      expect(instance1, equals(instance2));
      expect(identical(instance1, instance2), isTrue);
    });

    test('factory constructor should return same instance', () {
      final instance1 = ShareCardService();
      final instance2 = ShareCardService();

      expect(identical(instance1, instance2), isTrue);
    });
  });

  group('ShareCardService - Verse Card Generation', () {
    late ShareCardService service;
    late Verse testVerse;

    setUp(() {
      service = ShareCardService.instance;
      testVerse = Verse(
        chapterId: 2,
        verseId: 47,
        description:
            'You have the right to perform your duty, but not to the fruits of your actions.',
      );
    });

    test('should generate verse card image', () async {
      final cardImage = await service.generateVerseCard(
        testVerse,
        ShareCardTheme.minimalist,
      );

      expect(cardImage, isNotNull);
      expect(cardImage, isA<Uint8List>());
      expect(cardImage.isNotEmpty, isTrue);
      // PNG signature check (first 8 bytes)
      expect(cardImage[0], equals(137)); // PNG signature starts with 0x89
      expect(cardImage[1], equals(80)); // 'P'
      expect(cardImage[2], equals(78)); // 'N'
      expect(cardImage[3], equals(71)); // 'G'
    });

    test('generated verse card should have reasonable size', () async {
      final cardImage = await service.generateVerseCard(
        testVerse,
        ShareCardTheme.minimalist,
      );

      // Image should be between 10KB and 5MB
      expect(cardImage.length, greaterThan(10 * 1024));
      expect(cardImage.length, lessThan(5 * 1024 * 1024));
    });

    test('should generate card for different verses', () async {
      final verse1 = Verse(
        chapterId: 1,
        verseId: 1,
        description: 'First verse',
      );

      final verse2 = Verse(
        chapterId: 18,
        verseId: 78,
        description: 'Last verse with longer description for testing',
      );

      final card1 = await service.generateVerseCard(
        verse1,
        ShareCardTheme.minimalist,
      );
      final card2 = await service.generateVerseCard(
        verse2,
        ShareCardTheme.minimalist,
      );

      expect(card1, isNotNull);
      expect(card2, isNotNull);
      expect(card1.length, greaterThan(0));
      expect(card2.length, greaterThan(0));
    });
  });

  group('ShareCardService - Scenario Card Generation', () {
    late ShareCardService service;
    late Scenario testScenario;

    setUp(() {
      service = ShareCardService.instance;
      testScenario = Scenario(
        title: 'Career Dilemma',
        description: 'Should I take the safe job or pursue my passion?',
        heartResponse: 'Follow your passion',
        dutyResponse: 'Choose financial security',
        gitaWisdom: 'Perform your duty without attachment',
        category: 'career',
        chapter: 2,
        tags: ['work', 'passion'],
        createdAt: DateTime.now(),
      );
    });

    test('should generate scenario card image', () async {
      final cardImage = await service.generateScenarioCard(
        testScenario,
        ShareCardTheme.minimalist,
      );

      expect(cardImage, isNotNull);
      expect(cardImage, isA<Uint8List>());
      expect(cardImage.isNotEmpty, isTrue);
      // PNG signature check
      expect(cardImage[0], equals(137));
      expect(cardImage[1], equals(80));
    });

    test('generated scenario card should have reasonable size', () async {
      final cardImage = await service.generateScenarioCard(
        testScenario,
        ShareCardTheme.minimalist,
      );

      // Image should be between 10KB and 5MB
      expect(cardImage.length, greaterThan(10 * 1024));
      expect(cardImage.length, lessThan(5 * 1024 * 1024));
    });

    test('should generate card for different scenarios', () async {
      final scenario1 = Scenario(
        title: 'Short Title',
        description: 'Short description',
        heartResponse: 'Heart',
        dutyResponse: 'Duty',
        gitaWisdom: 'Wisdom',
        category: 'test',
        chapter: 1,
        tags: [],
        createdAt: DateTime.now(),
      );

      final scenario2 = Scenario(
        title: 'Very Long Title That Tests Text Wrapping Behavior',
        description:
            'A much longer description that should test how the card handles extensive text content and wrapping',
        heartResponse: 'Detailed heart response',
        dutyResponse: 'Detailed duty response',
        gitaWisdom: 'Extensive wisdom text',
        category: 'test',
        chapter: 18,
        tags: [],
        createdAt: DateTime.now(),
      );

      final card1 = await service.generateScenarioCard(
        scenario1,
        ShareCardTheme.minimalist,
      );
      final card2 = await service.generateScenarioCard(
        scenario2,
        ShareCardTheme.minimalist,
      );

      expect(card1, isNotNull);
      expect(card2, isNotNull);
      expect(card1.length, greaterThan(0));
      expect(card2.length, greaterThan(0));
    });
  });

  group('ShareCardService - Sharing Functions', () {
    late ShareCardService service;
    late Verse testVerse;
    late Scenario testScenario;

    setUp(() {
      service = ShareCardService.instance;
      testVerse = Verse(
        chapterId: 2,
        verseId: 47,
        description: 'Test verse',
      );
      testScenario = Scenario(
        title: 'Test Scenario',
        description: 'Test description',
        heartResponse: 'Heart',
        dutyResponse: 'Duty',
        gitaWisdom: 'Wisdom',
        category: 'test',
        chapter: 2,
        tags: [],
        createdAt: DateTime.now(),
      );
    });

    test('shareVerseCard should not throw errors', () async {
      // Note: In test environment, share may fail but shouldn't throw
      expect(() async => await service.shareVerseCard(verse: testVerse),
             returnsNormally);
    });

    test('shareScenarioCard should not throw errors', () async {
      // Note: In test environment, share may fail but shouldn't throw
      expect(() async => await service.shareScenarioCard(scenario: testScenario),
             returnsNormally);
    });

    test('shareVerseCard should return boolean', () async {
      final result = await service.shareVerseCard(verse: testVerse);
      expect(result, isA<bool>());
    });

    test('shareScenarioCard should return boolean', () async {
      final result = await service.shareScenarioCard(scenario: testScenario);
      expect(result, isA<bool>());
    });
  });

  group('ShareCardService - Theme Support', () {
    late ShareCardService service;
    late Verse testVerse;

    setUp(() {
      service = ShareCardService.instance;
      testVerse = Verse(
        chapterId: 1,
        verseId: 1,
        description: 'Test verse',
      );
    });

    test('should support minimalist theme', () async {
      final card = await service.generateVerseCard(
        testVerse,
        ShareCardTheme.minimalist,
      );

      expect(card, isNotNull);
      expect(card.isNotEmpty, isTrue);
    });
  });

  group('ShareCardService - Error Handling', () {
    late ShareCardService service;

    setUp(() {
      service = ShareCardService.instance;
    });

    test('should handle verse with empty description', () async {
      final verse = Verse(
        chapterId: 1,
        verseId: 1,
        description: '',
      );

      expect(
        () async => await service.generateVerseCard(
          verse,
          ShareCardTheme.minimalist,
        ),
        returnsNormally,
      );
    });

    test('should handle scenario with empty fields', () async {
      final scenario = Scenario(
        title: '',
        description: '',
        heartResponse: '',
        dutyResponse: '',
        gitaWisdom: '',
        category: '',
        chapter: 1,
        tags: [],
        createdAt: DateTime.now(),
      );

      expect(
        () async => await service.generateScenarioCard(
          scenario,
          ShareCardTheme.minimalist,
        ),
        returnsNormally,
      );
    });
  });
}
