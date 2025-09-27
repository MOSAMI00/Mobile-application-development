// lib/features/currency_exchange/services/exchange_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_key.dart';

class ExchangeApi {
  static Future<Map<String, dynamic>> fetchRates() async {
    var response = await http.get(Uri.parse(
        'https://openexchangerates.org/api/latest.json?base=USD&app_id=$apiKey'));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('فشل في تحميل أسعار الصرف');
    }
  }

  static Future<Map<String, String>> fetchCurrencies() async {
    var response = await http.get(Uri.parse(
        'https://openexchangerates.org/api/currencies.json?app_id=$apiKey'));
    
    if (response.statusCode == 200) {
      return Map<String, String>.from(json.decode(response.body));
    } else {
      throw Exception('فشل في تحميل قائمة العملات');
    }
  }

  static String convertUsd(Map<String, dynamic> rates, String amount, String currency) {
    double rate = rates[currency] ?? 1.0;
    double result = rate * double.parse(amount);
    return result.toStringAsFixed(2);
  }

  static String convertAny(Map<String, dynamic> rates, String amount, 
                          String fromCurrency, String toCurrency) {
    double fromRate = rates[fromCurrency] ?? 1.0;
    double toRate = rates[toCurrency] ?? 1.0;
    double result = (double.parse(amount) / fromRate) * toRate;
    return result.toStringAsFixed(2);
  }
}