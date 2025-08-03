// lib/services/gita_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gita_daily/models/gita_models.dart';

class GitaApiService {
  Future<Verse?> getVerse(int chapter, int verse) async {
    final url = Uri.parse('https://bhagavadgitaapi.in/slok/$chapter/$verse/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return Verse.fromJson(json.decode(response.body));
      } else {
        // Handle server errors
        return null;
      }
    } catch (e) {
      // Handle network errors
      return null;
    }
  }
}