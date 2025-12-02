import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/income.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const bool USE_LOCAL_BACKEND = false;

  static String get BASE_URL {
    // if (USE_LOCAL_DEVICE) {
    //   //  Physical Android device
    //   return 'http://192.168.23.78:3700/api'; // usb -> 10.239.154.78 , wifi -> 192.168.23.78
    // } else {
    //   //  Android emulator
    //   return 'http://10.0.2.2:3700/api';
    // }
    if (USE_LOCAL_BACKEND) {
      return 'http://10.0.2.2:3700/api';
    } else {
      return 'https://budget-mate-backend-92121670304.europe-north1.run.app/api';
    }
  }

  // Fetch balance for a given year and month
  // static Future<double?> getBalance(int year, int month) async {
  //   final uri = Uri.parse('$BASE_URL/balance?year=$year&month=$month');
  //
  //   try {
  //     final response = await http.get(uri, headers: {
  //       'Content-Type': 'application/json',
  //     });
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       print('Balance response: $data');
  //       if (data is Map && data.containsKey('total_balance')) {
  //         return (data['total_balance'] as num?)?.toDouble() ?? 0.0;
  //       }
  //       return 0.0;
  //     } else {
  //       print('Balance API failed: ${response.statusCode}');
  //       return 0.0;
  //     }
  //   } catch (e) {
  //     print('Error fetching balance: $e');
  //     return 0.0;
  //   }
  // }

  // REGISTER USER
  static Future<Map<String, dynamic>> registerUser(
    String name,
    String email,
    String password,
  ) async {
    final url = Uri.parse("$BASE_URL/auth/register");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "message": data['message'] ?? "Registration failed",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  //  LOGIN USER
  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    final uri = Uri.parse('$BASE_URL/auth/login');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        //Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('email', email);
        if (data['user']?['name'] != null) {
          await prefs.setString('userName', data['user']['name']);
        }
        if (data['token'] != null) {
          await prefs.setString('authToken', data['token']);
        }

        return {'success': true, 'message': data['message'] ?? 'Login success'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<double?> getBalance(int year, int month) async {
    final uri = Uri.parse(
      '$BASE_URL/balance/month_year?year=$year&month=$month',
    );

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Balance response: $data');

        // Match your backend response key
        if (data is Map && data.containsKey('net_balance')) {
          return (data['net_balance'] as num?)?.toDouble() ?? 0.0;
        }

        return 0.0;
      } else {
        print('Balance API failed: ${response.statusCode}');
        return 0.0;
      }
    } catch (e) {
      print('Error fetching balance: $e');
      return 0.0;
    }
  }

  //logout

  static Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // POST /incomes  (Add new income)

  // static Future<bool> createIncome(Income income) async {
  //   final uri = Uri.parse('$BASE_URL/incomes');
  //   final headers = {'Content-Type': 'application/json'};
  //
  //   // send only fields accepted by backend
  //   final body = jsonEncode({
  //     'amount': income.amount,
  //     'category': income.category,
  //   });
  //
  //   try {
  //     final resp = await http.post(uri, headers: headers, body: body);
  //     debugPrint('POST /incomes → ${resp.statusCode} ${resp.body}');
  //     if (resp.statusCode == 200 || resp.statusCode == 201) return true;
  //     return false;
  //   } catch (e, st) {
  //     debugPrint('createIncome error: $e\n$st');
  //     return false;
  //   }
  // }

  static Future<bool> createIncome(Income income) async {
    try {
      final uri = Uri.parse('$BASE_URL/incomes');
      final body = jsonEncode({
        'amount': income.amount,
        'category': income.category,
        'year': DateTime.parse(income.timestamp).year,
        'month': DateTime.parse(income.timestamp).month,
      });

      final headers = {'Content-Type': 'application/json'};

      final resp = await http.post(uri, headers: headers, body: body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        print('Income added: ${resp.body}');
        return true;
      } else {
        print('Failed to add income: ${resp.statusCode} - ${resp.body}');
        return false;
      }
    } catch (e) {
      print('Error adding income: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getIncome(int year, int month) async {
    final url = Uri.parse(
      '$BASE_URL/incomes/get_income?year=$year&month=$month',
    );
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch income');
    }
    return jsonDecode(response.body);
  }

  //statisctics (get)
  static Future<Map<String, dynamic>> getStatistics(int year, int month) async {
    final url = Uri.parse(
      '$BASE_URL/incomes/statistics?year=$year&month=$month',
    );
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load statistics: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    print('Backend response: $body');
    return body is Map<String, dynamic> ? body : {};
  }

  //expense stat
  static Future<Map<String, dynamic>> getExpenseStatistics(
    int year,
    int month,
  ) async {
    final uri = Uri.parse(
      '$BASE_URL/expenses/statistics?year=$year&month=$month',
    );
    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Expense statistics API failed: ${response.statusCode}");
        return {};
      }
    } catch (e) {
      print("Error fetching expense statistics: $e");
      return {};
    }
  }

  // ADD EXPENSE
  static Future<bool> createExpense(Map<String, dynamic> expenseData) async {
    final url = Uri.parse('$BASE_URL/expenses');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(expenseData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Expense Added: ${response.body}");
      return true;
    } else {
      print("Expense Error: ${response.statusCode} - ${response.body}");
      return false;
    }
  }

  //get expenses for a given year and month
  static Future<double?> getTotalExpenses(int year, int month) async {
    final url = Uri.parse(
      '$BASE_URL/expenses/total_expenses?year=$year&month=$month',
    );
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (body['total_expense'] != null)
          ? double.tryParse(body['total_expense'].toString())
          : 0.0;
    } else {
      throw Exception('Failed to load total expenses');
    }
  }

  // show recent expenses in home screen
  static Future<Map<String, dynamic>> getExpenses(int year, int month) async {
    final url = Uri.parse(
      '$BASE_URL/expenses/get_expenses?year=$year&month=$month',
    );
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load expenses');
    }

    final body = jsonDecode(response.body);

    // ✅ Make sure it always returns a valid structure
    return {
      'label': body['label'] ?? '',
      'total_expense': double.tryParse(body['total_expense'].toString()) ?? 0.0,
      'expenses': body['expenses'] ?? [],
    };
  }

  static Future<bool> updateExpense(
    String id,
    double amount,
    String note,
  ) async {
    final url = Uri.parse('$BASE_URL/expenses/$id');
    final body = jsonEncode({"amount": amount, "note": note});
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteExpense(String id) async {
    final url = Uri.parse('$BASE_URL/expenses/$id');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }
}
