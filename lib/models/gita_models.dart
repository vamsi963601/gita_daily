// lib/models/gita_models.dart
class Verse {
  final int chapterNumber;
  final int verseNumber;
  final String text;
  final String transliteration;
  final String meaning;

  Verse({
    required this.chapterNumber,
    required this.verseNumber,
    required this.text,
    required this.transliteration,
    required this.meaning,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      chapterNumber: json['chapter_number'],
      verseNumber: json['verse_number'],
      text: json['text'],
      transliteration: json['transliteration'],
      meaning: json['meaning'], // Assuming a simple 'meaning' field for this example
    );
  }
}