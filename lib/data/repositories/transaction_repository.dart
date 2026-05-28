import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app_finances_oat/data/local/app_database.dart';
import 'package:app_finances_oat/data/services/supabase_sync_service.dart';
import 'package:app_finances_oat/models/transaction_model.dart';
import 'package:sqflite/sqflite.dart';

class TransactionRepository {
  final AppDatabase _appDatabase;

  TransactionRepository(this._appDatabase);

  // In-memory fallback for Web
  static final List<TransactionModel> _webTransactions = [];
  static int _webTxIdCounter = 1;

  Future<List<TransactionModel>> getTransactions(int userId) async {
    List<TransactionModel> localTxs = [];

    if (kIsWeb) {
      localTxs = _webTransactions.where((t) => t.userId == userId).toList();
      localTxs.sort((a, b) => b.date.compareTo(a.date));
    } else {
      try {
        final db = await _appDatabase.database;
        final results = await db.query(
          'transactions',
          where: 'userId = ?',
          whereArgs: [userId],
          orderBy: 'date DESC',
        );
        localTxs = results.map(TransactionModel.fromMap).toList();
      } catch (e) {
        throw Exception('Erro ao buscar transações: $e');
      }
    }

    // Se o banco local estiver vazio, tenta sincronizar e restaurar a partir da nuvem do Supabase
    if (localTxs.isEmpty && SupabaseSyncService.instance.isConfigured) {
      final remoteTxs = await SupabaseSyncService.instance.fetchRemoteTransactions(userId);
      if (remoteTxs.isNotEmpty) {
        // Salva as transações remotas no banco local para uso offline futuro
        for (var tx in remoteTxs) {
          if (kIsWeb) {
            _webTransactions.add(tx);
            if (tx.id != null && tx.id! >= _webTxIdCounter) {
              _webTxIdCounter = tx.id! + 1;
            }
          } else {
            try {
              final db = await _appDatabase.database;
              await db.insert('transactions', tx.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
            } catch (_) {}
          }
        }
        localTxs = remoteTxs;
        localTxs.sort((a, b) => b.date.compareTo(a.date));
      }
    }

    return localTxs;
  }

  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    TransactionModel added;

    if (kIsWeb) {
      added = transaction.copyWith(id: _webTxIdCounter++);
      _webTransactions.add(added);
    } else {
      try {
        final db = await _appDatabase.database;
        final id = await db.insert('transactions', transaction.toMap());
        added = transaction.copyWith(id: id);
      } catch (e) {
        throw Exception('Erro ao adicionar transação: $e');
      }
    }

    // Sincroniza em segundo plano com o Supabase
    if (SupabaseSyncService.instance.isConfigured) {
      await SupabaseSyncService.instance.syncTransaction(added);
    }

    return added;
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    if (kIsWeb) {
      final index = _webTransactions.indexWhere((t) => t.id == transaction.id);
      if (index == -1) {
        throw Exception('Transação não encontrada');
      }
      _webTransactions[index] = transaction;
    } else {
      try {
        final db = await _appDatabase.database;
        final rowsAffected = await db.update(
          'transactions',
          transaction.toMap(),
          where: 'id = ?',
          whereArgs: [transaction.id],
        );
        if (rowsAffected == 0) {
          throw Exception('Transação não encontrada');
        }
      } catch (e) {
        throw Exception('Erro ao atualizar transação: $e');
      }
    }

    // Sincroniza em segundo plano com o Supabase
    if (SupabaseSyncService.instance.isConfigured) {
      await SupabaseSyncService.instance.syncTransaction(transaction);
    }
  }

  Future<void> deleteTransaction(int id) async {
    if (kIsWeb) {
      final index = _webTransactions.indexWhere((t) => t.id == id);
      if (index == -1) {
        throw Exception('Transação não encontrada');
      }
      _webTransactions.removeAt(index);
    } else {
      try {
        final db = await _appDatabase.database;
        final rowsAffected = await db.delete(
          'transactions',
          where: 'id = ?',
          whereArgs: [id],
        );
        if (rowsAffected == 0) {
          throw Exception('Transação não encontrada');
        }
      } catch (e) {
        throw Exception('Erro ao excluir transação: $e');
      }
    }

    // Exclui em segundo plano no Supabase
    if (SupabaseSyncService.instance.isConfigured) {
      await SupabaseSyncService.instance.deleteRemoteTransaction(id);
    }
  }

  Future<List<TransactionModel>> getTransactionsByType(
    int userId,
    TransactionType type,
  ) async {
    // Como os dados da nuvem já são restaurados e cacheados localmente na primeira chamada ao 'getTransactions',
    // a busca por tipo pode consultar diretamente o banco local para máxima performance.
    if (kIsWeb) {
      final txs = _webTransactions
          .where((t) => t.userId == userId && t.type == type)
          .toList();
      txs.sort((a, b) => b.date.compareTo(a.date));
      return txs;
    }

    try {
      final db = await _appDatabase.database;
      final results = await db.query(
        'transactions',
        where: 'userId = ? AND type = ?',
        whereArgs: [userId, type.name],
        orderBy: 'date DESC',
      );
      return results.map(TransactionModel.fromMap).toList();
    } catch (e) {
      throw Exception('Erro ao buscar transações por tipo: $e');
    }
  }
}
