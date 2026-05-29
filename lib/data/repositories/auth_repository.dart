import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app_finances_oat/core/constants/app_strings.dart';
import 'package:app_finances_oat/data/local/app_database.dart';
import 'package:app_finances_oat/data/services/supabase_sync_service.dart';
import 'package:app_finances_oat/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

class AuthRepository {
  final AppDatabase _appDatabase;

  AuthRepository(this._appDatabase);

  // In-memory fallback for Web
  static final List<User> _webUsers = [];
  static int _webUserIdCounter = 1;

  Future<User> registerUser(User user) async {
    User registered;
    if (kIsWeb) {
      final exists = _webUsers.any((u) => u.email == user.email);
      if (exists) {
        throw Exception(AppStrings.emailAlreadyExists);
      }
      registered = user.copyWith(
        id: _webUserIdCounter++,
        createdAt: DateTime.now().toIso8601String(),
      );
      _webUsers.add(registered);
    } else {
      try {
        final db = await _appDatabase.database;
        final id = await db.insert(
          'users',
          user.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
        registered = user.copyWith(id: id);
      } on DatabaseException catch (e) {
        if (e.isUniqueConstraintError()) {
          throw Exception(AppStrings.emailAlreadyExists);
        }
        rethrow;
      }
    }

    // Sincroniza em segundo plano com o Supabase
    if (SupabaseSyncService.instance.isConfigured) {
      await SupabaseSyncService.instance.syncUser(registered);
    }

    return registered;
  }

  Future<User?> loginUser(String email, String password) async {
    User? localUser;

    if (kIsWeb) {
      final match = _webUsers.where((u) => u.email == email && u.password == password);
      localUser = match.isEmpty ? null : match.first;
    } else {
      try {
        final db = await _appDatabase.database;
        final results = await db.query(
          'users',
          where: 'email = ? AND password = ?',
          whereArgs: [email, password],
          limit: 1,
        );
        if (results.isNotEmpty) {
          localUser = User.fromMap(results.first);
        }
      } catch (e) {
        throw Exception('${AppStrings.error}: $e');
      }
    }

    // Se o usuário existe localmente, retorna ele
    if (localUser != null) {
      return localUser;
    }

    // Se não for encontrado localmente, busca no Supabase
    if (SupabaseSyncService.instance.isConfigured) {
      final remoteUser = await SupabaseSyncService.instance.getRemoteUser(email, password);
      if (remoteUser != null) {
        // Cacheia localmente para uso offline futuro
        if (kIsWeb) {
          _webUsers.add(remoteUser);
          if (remoteUser.id != null && remoteUser.id! >= _webUserIdCounter) {
            _webUserIdCounter = remoteUser.id! + 1;
          }
        } else {
          try {
            final db = await _appDatabase.database;
            await db.insert(
              'users',
              remoteUser.toMap(),
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          } catch (_) {}
        }
        return remoteUser;
      }
    }

    return null;
  }

  Future<User?> getUserById(int id) async {
    User? localUser;

    if (kIsWeb) {
      final match = _webUsers.where((u) => u.id == id);
      localUser = match.isEmpty ? null : match.first;
    } else {
      try {
        final db = await _appDatabase.database;
        final results = await db.query(
          'users',
          where: 'id = ?',
          whereArgs: [id],
          limit: 1,
        );
        if (results.isNotEmpty) {
          localUser = User.fromMap(results.first);
        }
      } catch (e) {
        throw Exception('${AppStrings.error}: $e');
      }
    }

    if (localUser != null) {
      return localUser;
    }

    // Se não encontrado localmente, busca no Supabase
    if (SupabaseSyncService.instance.isConfigured) {
      final remoteUser = await SupabaseSyncService.instance.getRemoteUserById(id);
      if (remoteUser != null) {
        // Cacheia localmente
        if (kIsWeb) {
          _webUsers.add(remoteUser);
        } else {
          try {
            final db = await _appDatabase.database;
            await db.insert(
              'users',
              remoteUser.toMap(),
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          } catch (_) {}
        }
        return remoteUser;
      }
    }

    return null;
  }

  Future<User> updateUser(User user) async {
    if (kIsWeb) {
      final index = _webUsers.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        final emailExists = _webUsers.any((u) => u.email == user.email && u.id != user.id);
        if (emailExists) {
          throw Exception(AppStrings.emailAlreadyExists);
        }
        _webUsers[index] = user;
      } else {
        throw Exception("Usuário não encontrado.");
      }
    } else {
      try {
        final db = await _appDatabase.database;
        await db.update(
          'users',
          user.toMap(),
          where: 'id = ?',
          whereArgs: [user.id],
        );
      } on DatabaseException catch (e) {
        if (e.isUniqueConstraintError()) {
          throw Exception(AppStrings.emailAlreadyExists);
        }
        rethrow;
      }
    }

    // Sincroniza em segundo plano com o Supabase
    if (SupabaseSyncService.instance.isConfigured) {
      await SupabaseSyncService.instance.syncUser(user);
    }

    return user;
  }
}
