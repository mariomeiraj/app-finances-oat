import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_finances_oat/app.dart';
import 'package:app_finances_oat/core/config/env_config.dart';
import 'package:app_finances_oat/data/local/db_initializer.dart'
    if (dart.library.io) 'package:app_finances_oat/data/local/db_initializer_desktop.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDatabaseFactory();
  await EnvConfig.init();
  await initializeDateFormatting('pt_BR', null);

  // Inicializa o Supabase caso as chaves estejam preenchidas
  if (EnvConfig.supabaseUrl.isNotEmpty && EnvConfig.supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Falha ao inicializar o Supabase: $e');
    }
  }

  runApp(const ProviderScope(child: App()));
}
