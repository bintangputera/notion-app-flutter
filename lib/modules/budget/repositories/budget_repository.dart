import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:notion_app_flutter/constants/api_constant.dart';
import 'package:notion_app_flutter/modules/budget/model/budget.dart';
import 'package:notion_app_flutter/utils/failure.dart';

class BudgetRepository {
  final http.Client _client;

  BudgetRepository({http.Client? client}) : _client = client ?? http.Client();

  void dispose() {
    _client.close();
  }

  Future<List<Budget>> getItems() async {
    try {
      final url =
          '$BASE_URL/databases/${dotenv.env['NOTION_DATABASE_ID']}/query';
      final response = await _client.post(Uri.parse(url), headers: {
        HttpHeaders.authorizationHeader:
            'Bearer ${dotenv.env['NOTION_API_KEY']}',
        'Notion-Version': '2021-05-13',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['results'] as List).map((e) => Budget.fromMap(e)).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      } else {
        throw const Failure(message: 'Something went wrong');
      }
    } catch (_) {
      throw const Failure(message: 'Something went wrong');
    }
  }
}
