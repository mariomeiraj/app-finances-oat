import 'dart:convert';

import 'package:app_finances_oat/core/config/env_config.dart';
import 'package:app_finances_oat/models/currency_model.dart';
import 'package:http/http.dart' as http;

class CurrencyRepository {
  static const String _baseUrl =
      'https://economia.awesomeapi.com.br/json/last';

  Future<List<CurrencyModel>> fetchRates() async {
    final token = EnvConfig.awesomeApiKey;
    final urlString = '$_baseUrl/USD-BRL,EUR-BRL,BTC-BRL${token.isNotEmpty ? '?token=$token' : ''}';
    final response = await http.get(Uri.parse(urlString));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar cotações');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final List<CurrencyModel> currencies = [];

    for (final entry in data.entries) {
      final map = entry.value as Map<String, dynamic>;
      currencies.add(CurrencyModel(
        code: map['code'] as String,
        name: map['name'] as String,
        buyPrice: double.tryParse(map['bid']?.toString() ?? '0') ?? 0.0,
        sellPrice: double.tryParse(map['ask']?.toString() ?? '0') ?? 0.0,
        variation:
            double.tryParse(map['pctChange']?.toString() ?? '0') ?? 0.0,
        updatedAt: DateTime.tryParse(
                map['create_date']?.toString() ?? '') ??
            DateTime.now(),
      ));
    }

    return currencies;
  }
}
