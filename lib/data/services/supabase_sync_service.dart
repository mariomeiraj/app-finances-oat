import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:app_finances_oat/models/user_model.dart';
import 'package:app_finances_oat/models/transaction_model.dart';
import 'package:app_finances_oat/core/config/env_config.dart';

class SupabaseSyncService {
  static final SupabaseSyncService instance = SupabaseSyncService._();
  SupabaseSyncService._();

  bool get isConfigured =>
      EnvConfig.supabaseUrl.isNotEmpty && EnvConfig.supabaseAnonKey.isNotEmpty;

  SupabaseClient? get _client {
    if (!isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // --- MÉTODOS DE USUÁRIO ---

  /// Sincroniza um usuário cadastrado com o Supabase.
  Future<void> syncUser(User user) async {
    final client = _client;
    if (client == null) return;

    try {
      final userMap = {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'password': user.password,
        'created_at': user.createdAt ?? DateTime.now().toIso8601String(),
      };
      
      await client.from('users').upsert(userMap, onConflict: 'email');
      debugPrint('Usuário sincronizado com o Supabase: ${user.email}');
    } catch (e) {
      debugPrint('Erro ao sincronizar usuário no Supabase: $e');
    }
  }

  /// Busca um usuário na nuvem por email e senha.
  Future<User?> getRemoteUser(String email, String password) async {
    final client = _client;
    if (client == null) return null;

    try {
      final response = await client
          .from('users')
          .select()
          .eq('email', email)
          .eq('password', password)
          .maybeSingle();

      if (response != null) {
        return User(
          id: response['id'] as int,
          name: response['name'] as String,
          email: response['email'] as String,
          password: response['password'] as String,
          createdAt: response['created_at'] as String?,
        );
      }
    } catch (e) {
      debugPrint('Erro ao buscar usuário remoto no Supabase: $e');
    }
    return null;
  }

  /// Busca um usuário na nuvem por ID.
  Future<User?> getRemoteUserById(int id) async {
    final client = _client;
    if (client == null) return null;

    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response != null) {
        return User(
          id: response['id'] as int,
          name: response['name'] as String,
          email: response['email'] as String,
          password: response['password'] as String,
          createdAt: response['created_at'] as String?,
        );
      }
    } catch (e) {
      debugPrint('Erro ao buscar usuário remoto por ID: $e');
    }
    return null;
  }

  // --- MÉTODOS DE TRANSAÇÃO ---

  /// Sincroniza uma transação única (adicionar/editar) com o Supabase.
  Future<void> syncTransaction(TransactionModel transaction) async {
    final client = _client;
    if (client == null) return;

    try {
      final txMap = {
        'id': transaction.id,
        'user_id': transaction.userId,
        'title': transaction.title,
        'amount': transaction.amount,
        'type': transaction.type.name,
        'category': transaction.category,
        'date': transaction.date.toIso8601String(),
      };

      await client.from('transactions').upsert(txMap);
      debugPrint('Transação sincronizada com o Supabase: ${transaction.title}');
    } catch (e) {
      debugPrint('Erro ao sincronizar transação no Supabase: $e');
    }
  }

  /// Exclui uma transação remotamente na nuvem do Supabase.
  Future<void> deleteRemoteTransaction(int transactionId) async {
    final client = _client;
    if (client == null) return;

    try {
      await client.from('transactions').delete().eq('id', transactionId);
      debugPrint('Transação excluída do Supabase, ID: $transactionId');
    } catch (e) {
      debugPrint('Erro ao excluir transação remota no Supabase: $e');
    }
  }

  /// Busca todas as transações remotas de um determinado usuário.
  Future<List<TransactionModel>> fetchRemoteTransactions(int userId) async {
    final client = _client;
    if (client == null) return [];

    try {
      final results = await client
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      return results.map<TransactionModel>((map) {
        return TransactionModel(
          id: map['id'] as int,
          userId: map['user_id'] as int,
          title: map['title'] as String,
          amount: (map['amount'] as num).toDouble(),
          type: map['type'] == 'income'
              ? TransactionType.income
              : TransactionType.expense,
          category: map['category'] as String? ?? 'Outros',
          date: DateTime.parse(map['date'] as String),
        );
      }).toList();
    } catch (e) {
      debugPrint('Erro ao carregar transações remotas do Supabase: $e');
      return [];
    }
  }
}
