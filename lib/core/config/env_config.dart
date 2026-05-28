import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;

class EnvConfig {
  static final Map<String, String> _env = {};

  static String get awesomeApiKey => _env['AWESOME_APIKEY'] ?? '';
  static String get supabaseUrl => _env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => _env['SUPABASE_ANON_KEY'] ?? '';

  static Future<void> init() async {
    try {
      final content = await rootBundle.loadString('.env');
      _parse(content);
    } catch (e) {
      // Aceitável falhar (ex: em testes onde o asset bundle não está disponível),
      // pois a AwesomeAPI funciona sem chave (com limites públicos)
      debugPrint('Erro ao carregar .env dos assets: $e');
    }
  }

  static void _parse(String content) {
    final lines = content.split('\n');
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      final parts = line.split('=');
      if (parts.length >= 2) {
        final key = parts[0].trim();
        final value = parts.sublist(1).join('=').trim();
        
        // Remove aspas simples ou duplas que envolvem o valor, se houver
        String cleanValue = value;
        if ((cleanValue.startsWith("'") && cleanValue.endsWith("'")) ||
            (cleanValue.startsWith('"') && cleanValue.endsWith('"'))) {
          cleanValue = cleanValue.substring(1, cleanValue.length - 1);
        }
        
        _env[key] = cleanValue;
      }
    }
  }
}
