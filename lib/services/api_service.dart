import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote_model.dart';

class ApiService {
  static const _base = 'https://api.quotable.io';

  static const _cacheKeyDaily = 'cache_daily_quote';
  static const _cacheTimeKeyDaily = 'cache_daily_quote_time';

  Future<QuoteModel> getRandomQuote() async {
    final res = await http.get(Uri.parse('$_base/random'));
    if (res.statusCode != 200) throw Exception('Falha ao obter citação.');
    return QuoteModel.fromJson(json.decode(res.body));
  }

  Future<List<QuoteModel>> searchQuotes(String query) async {
    final uri = Uri.parse('$_base/search/quotes?query=${Uri.encodeComponent(query)}&limit=10');
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Falha na pesquisa de citações.');
    final data = json.decode(res.body);
    final results = (data['results'] as List).cast<Map<String, dynamic>>();
    return results.map(QuoteModel.fromJson).toList();
  }

  Future<QuoteModel> getQuoteDetails(String id) async {
    final res = await http.get(Uri.parse('$_base/quotes/$id'));
    if (res.statusCode != 200) throw Exception('Falha ao obter detalhes da citação.');
    return QuoteModel.fromJson(json.decode(res.body));
  }

  Future<QuoteModel> getDailyQuoteCached() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt(_cacheTimeKeyDaily);
    final now = DateTime.now();

    if (lastMs != null) {
      final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
      final sameDay = last.year == now.year && last.month == now.month && last.day == now.day;
      if (sameDay) {
        final raw = prefs.getString(_cacheKeyDaily);
        if (raw != null) return QuoteModel.fromJson(json.decode(raw));
      }
    }

    final fresh = await getRandomQuote();
    await prefs.setString(_cacheKeyDaily, json.encode(fresh.toJson()));
    await prefs.setInt(_cacheTimeKeyDaily, now.millisecondsSinceEpoch);
    return fresh;
  }
}
