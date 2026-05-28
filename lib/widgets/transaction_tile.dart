import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:app_finances_oat/theme/app_theme.dart';
import 'package:app_finances_oat/models/transaction_model.dart';
import 'package:app_finances_oat/viewmodels/dashboard_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionTile extends ConsumerWidget {
  final TransactionModel transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = transaction.type == TransactionType.income;
    final isVisible = ref.watch(balanceVisibilityProvider);

    final amountColor = isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed;
    final amountPrefix = isIncome ? '+ ' : '- ';
    final formattedAmount = _formatCurrency(transaction.amount);
    final formattedDate = DateFormat('dd/MM', 'pt_BR').format(transaction.date);

    final bgColor = _categoryBgColor(transaction.category);
    final iconColor = _categoryIconColor(transaction.category);
    final iconData = _categoryIcon(transaction.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            iconData,
            color: iconColor,
            size: 20,
          ),
        ),
        title: Text(
          transaction.title,
          style: GoogleFonts.sora(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${transaction.category} • $formattedDate',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isVisible ? '$amountPrefix$formattedAmount' : r'R$ ••••',
              style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: amountColor,
              ),
            ),
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppTheme.textLight,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.dividerColor),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit?.call();
                  } else if (value == 'delete') {
                    onDelete?.call();
                  }
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textMedium),
                          const SizedBox(width: 8),
                          Text(
                            'Editar',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppTheme.expenseRed,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Excluir',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.expenseRed,
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
    );
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  Color _categoryBgColor(String category) {
    switch (category) {
      case 'Alimentação':
        return const Color(0xFFFEF3C7); // Amber 100
      case 'Transporte':
        return const Color(0xFFDBEAFE); // Blue 100
      case 'Lazer':
        return const Color(0xFFF3E8FF); // Purple 100
      case 'Saúde':
        return const Color(0xFFFEE2E2); // Red 100
      case 'Educação':
        return const Color(0xFFFAE8FF); // Fuchsia 100
      case 'Salário':
        return const Color(0xFFD1FAE5); // Emerald 100
      case 'Moradia':
        return const Color(0xFFCCFBF1); // Teal 100
      default:
        return const Color(0xFFF1F5F9); // Slate 100
    }
  }

  Color _categoryIconColor(String category) {
    switch (category) {
      case 'Alimentação':
        return const Color(0xFFD97706); // Amber 600
      case 'Transporte':
        return const Color(0xFF2563EB); // Blue 600
      case 'Lazer':
        return const Color(0xFF9333EA); // Purple 600
      case 'Saúde':
        return const Color(0xFFDC2626); // Red 600
      case 'Educação':
        return const Color(0xFFC084FC); // Fuchsia 600
      case 'Salário':
        return const Color(0xFF059669); // Emerald 600
      case 'Moradia':
        return const Color(0xFF0D9488); // Teal 600
      default:
        return const Color(0xFF64748B); // Slate 500
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Alimentação':
        return Icons.restaurant_rounded;
      case 'Transporte':
        return Icons.directions_car_rounded;
      case 'Lazer':
        return Icons.sports_esports_rounded;
      case 'Saúde':
        return Icons.local_hospital_rounded;
      case 'Educação':
        return Icons.school_rounded;
      case 'Salário':
        return Icons.savings_rounded;
      case 'Moradia':
        return Icons.home_rounded;
      case 'Outros':
        return Icons.widgets_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }
}
