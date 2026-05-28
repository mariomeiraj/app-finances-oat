import 'package:flutter/material.dart';
import 'package:app_finances_oat/views/auth/auth_view.dart';
import 'package:app_finances_oat/views/shell/main_shell.dart';

abstract class AppRoutes {
  static const auth = '/auth';
  static const home = '/home';

  static Map<String, WidgetBuilder> get routes => {
        auth: (_) => const AuthView(),
        home: (_) => const MainShell(),
      };
}
