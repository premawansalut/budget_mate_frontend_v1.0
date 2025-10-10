import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/income.dart';

class ApiService {

  static const bool USE_LOCAL_DEVICE = false; // change to false  using emulator

  static String get BASE_URL {
    if (USE_LOCAL_DEVICE) {
      //  Physical Android device
      return 'http://192.168.23.78:3500/api';
    } else {
      //  Android emulator
      return 'http://10.0.2.2:3500/api';
    }
  }


  // Fetch balance for a given year and month

  static Future<double?> getBalance(int year, int month) async {
    try {
      final uri = Uri.parse('$BASE_URL/balance?year=$year&month=$month');
      final resp = await http.get(uri);

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['total_balance'] != null) {
          return (data['total_balance'] as num).toDouble();
        } else {
          return 0.0;
        }
      } else if (resp.statusCode == 404) {
        // No data for that month
        return 0.0;
      } else {
        print('⚠️ Error fetching balance: ${resp.statusCode} - ${resp.body}');
        return 0.0;
      }
    } catch (e) {
      print('❌ Exception fetching balance: $e');
      return 0.0;
    }
  }


  // POST /incomes  (Add new income)

  static Future<bool> createIncome(Income income) async {
    final uri = Uri.parse('$BASE_URL/incomes');
    final headers = {'Content-Type': 'application/json'};

    // send only fields accepted by backend
    final body = jsonEncode({
      'amount': income.amount,
      'category': income.category,
    });

    try {
      final resp = await http.post(uri, headers: headers, body: body);
      debugPrint('POST /incomes → ${resp.statusCode} ${resp.body}');
      if (resp.statusCode == 200 || resp.statusCode == 201) return true;
      return false;
    } catch (e, st) {
      debugPrint('createIncome error: $e\n$st');
      return false;
    }
  }
}
