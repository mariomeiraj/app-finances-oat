import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:app_finances_oat/theme/app_theme.dart';
import 'package:app_finances_oat/models/transaction_model.dart';
import 'package:app_finances_oat/viewmodels/auth_viewmodel.dart';
import 'package:app_finances_oat/viewmodels/dashboard_viewmodel.dart';
import 'package:app_finances_oat/viewmodels/transactions_viewmodel.dart';
import 'package:app_finances_oat/widgets/add_transaction_modal.dart';
import 'package:app_finances_oat/widgets/empty_state.dart';
import 'package:app_finances_oat/widgets/transaction_tile.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;

    if (user == null) return const SizedBox.shrink();

    final int userId = user.id!;
    final totals = ref.watch(dashboardStateProvider(userId));
    final recentTransactions = totals.recentTransactions;

    ref.listen(transactionsViewModelProvider(userId), (previous, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        ref
            .read(transactionsViewModelProvider(userId).notifier)
            .clearMessages();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppTheme.expenseRed,
          ),
        );
        ref
            .read(transactionsViewModelProvider(userId).notifier)
            .clearMessages();
      }
    });

    final isVisible = ref.watch(balanceVisibilityProvider);
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    // Cálculo dinâmico do insight financeiro inteligente
    String insightTitle = '';
    String insightDescription = '';
    IconData insightIcon = Icons.lightbulb_rounded;
    Color insightColor = AppTheme.primaryGreen;

    if (recentTransactions.isEmpty) {
      insightTitle = 'Bem-vindo ao Koins!';
      insightDescription = 'Toque no "+" abaixo para registrar uma transação e gerar seus primeiros insights financeiros inteligentes.';
      insightIcon = Icons.waving_hand_rounded;
      insightColor = AppTheme.balanceBlue;
    } else if (totals.totalBalance > 0) {
      insightTitle = 'Saldo Saudável!';
      insightDescription = 'Suas receitas superaram suas despesas em ${formatter.format(totals.totalBalance)}. Continue poupando!';
      insightIcon = Icons.stars_rounded;
      insightColor = AppTheme.incomeGreen;
    } else if (totals.totalBalance < 0) {
      insightTitle = 'Atenção aos Gastos';
      insightDescription = 'Suas despesas superaram suas receitas em ${formatter.format(totals.totalBalance.abs())}. É hora de rever gastos desnecessários.';
      insightIcon = Icons.warning_amber_rounded;
      insightColor = AppTheme.expenseRed;
    } else {
      insightTitle = 'Equilíbrio Financeiro';
      insightDescription = 'Você gastou exatamente o que ganhou. Que tal tentar poupar um pouco mais no próximo mês?';
      insightIcon = Icons.balance_rounded;
      insightColor = Colors.orange;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho Fintech Premium
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, ${user.name}',
                        style: GoogleFonts.sora(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bem-vindo ao Koins',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Hero Card do Saldo (Estilo Cartão Fintech)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF1E293B),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saldo em conta',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textLight.withValues(alpha: 0.7),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => ref
                              .read(balanceVisibilityProvider.notifier)
                              .state = !isVisible,
                          child: Icon(
                            isVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isVisible
                            ? formatter.format(totals.totalBalance)
                            : r'R$ •••••',
                        style: GoogleFonts.sora(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_downward_rounded,
                                  color: Color(0xFF34D399),
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Receitas',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: AppTheme.textLight
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        isVisible
                                            ? formatter.format(totals.totalIncome)
                                            : r'R$ ••••',
                                        style: GoogleFonts.sora(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1.5,
                          height: 24,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_upward_rounded,
                                  color: Color(0xFFF87171),
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Despesas',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: AppTheme.textLight
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        isVisible
                                            ? formatter.format(totals.totalExpenses)
                                            : r'R$ ••••',
                                        style: GoogleFonts.sora(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Insight Inteligente (Feature Extra Wow)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: insightColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: insightColor.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(insightIcon, color: insightColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insightTitle,
                            style: GoogleFonts.sora(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            insightDescription,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Título do Histórico
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Histórico',
                    style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Icon(
                    Icons.history_toggle_off_rounded,
                    color: AppTheme.textSecondary.withValues(alpha: 0.4),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Lista Extrato
              Expanded(
                child: recentTransactions.isEmpty
                    ? const EmptyState(
                        title: 'Nenhuma transação ainda',
                        subtitle: 'Toque no + para adicionar.',
                        icon: Icons.receipt_long_rounded,
                      )
                    : ListView.builder(
                        itemCount: recentTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = recentTransactions[index];
                          return TransactionTile(
                            transaction: transaction,
                            onEdit: () => _showTransactionModal(
                              context,
                              ref,
                              userId,
                              existingTransaction: transaction,
                            ),
                            onDelete: () => _confirmDelete(
                              context,
                              ref,
                              userId,
                              transaction.id!,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionModal(context, ref, userId),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTransactionModal(
    BuildContext context,
    WidgetRef ref,
    int userId, {
    TransactionModel? existingTransaction,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddTransactionModal(
        userId: userId,
        existingTransaction: existingTransaction,
        onSave: (transaction) {
          final notifier = ref.read(transactionsViewModelProvider(userId).notifier);
          if (existingTransaction != null) {
            notifier.updateTransaction(transaction);
          } else {
            notifier.addTransaction(transaction);
          }
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int userId,
    int transactionId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir transação'),
        content: const Text('Deseja realmente excluir esta transação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(transactionsViewModelProvider(userId).notifier)
                  .deleteTransaction(transactionId);
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.expenseRed),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
