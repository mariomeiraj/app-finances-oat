import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:app_finances_oat/theme/app_theme.dart';
import 'package:app_finances_oat/viewmodels/auth_viewmodel.dart';
import 'package:app_finances_oat/viewmodels/analytics_viewmodel.dart';
import 'package:app_finances_oat/viewmodels/transactions_viewmodel.dart';
import 'package:app_finances_oat/viewmodels/dashboard_viewmodel.dart';
import 'package:app_finances_oat/widgets/empty_state.dart';

class AnalyticsView extends ConsumerWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;

    if (user == null) return const SizedBox.shrink();

    final int userId = user.id!;
    final analytics = ref.watch(analyticsDataProvider(userId));
    final txState = ref.watch(transactionsViewModelProvider(userId));
    final isVisible = ref.watch(balanceVisibilityProvider);
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    if (txState.transactions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Análise')),
        body: const EmptyState(
          title: 'Nenhuma transação ainda',
          subtitle: 'Adicione transações para ver análises',
          icon: Icons.bar_chart_rounded,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Análise Financeira',
          style: GoogleFonts.sora(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow(analytics, formatter, isVisible),
            const SizedBox(height: 20),
            _buildBarChartCard(analytics, formatter, isVisible),
            const SizedBox(height: 20),
            _buildPieChartCard(analytics, formatter, isVisible),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(AnalyticsData analytics, NumberFormat formatter, bool isVisible) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.incomeGreen.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.incomeGreen.withOpacity(0.12)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.incomeGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_downward_rounded,
                      color: AppTheme.incomeGreen, size: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Receitas',
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isVisible ? formatter.format(analytics.totalIncome) : r'R$ ••••',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.incomeGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.expenseRed.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.expenseRed.withOpacity(0.12)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.expenseRed.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_upward_rounded,
                      color: AppTheme.expenseRed, size: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Despesas',
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isVisible ? formatter.format(analytics.totalExpenses) : r'R$ ••••',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.expenseRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChartCard(AnalyticsData analytics, NumberFormat formatter, bool isVisible) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Receitas vs Despesas',
            style: GoogleFonts.sora(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(analytics),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label =
                          rodIndex == 0 ? 'Receitas' : 'Despesas';
                      return BarTooltipItem(
                        '$label\n${isVisible ? formatter.format(rod.toY) : r'R$ ••••'}',
                        GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final titles = ['Receitas', 'Despesas'];
                        if (value.toInt() < titles.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              titles[value.toInt()],
                              style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: analytics.totalIncome,
                        color: AppTheme.incomeGreen,
                        width: 36,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: analytics.totalExpenses,
                        color: AppTheme.expenseRed,
                        width: 36,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(AnalyticsData analytics, NumberFormat formatter, bool isVisible) {
    final categories = analytics.expensesByCategory.entries.toList();
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Despesas por categoria',
            style: GoogleFonts.sora(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 40,
                sections: List.generate(categories.length, (index) {
                  final entry = categories[index];
                  final color = _categoryIconColor(entry.key);
                  final percentage =
                      analytics.totalExpenses > 0 ? (entry.value / analytics.totalExpenses) * 100 : 0.0;
                  return PieChartSectionData(
                    value: entry.value,
                    color: color,
                    radius: 44,
                    title: '${percentage.toStringAsFixed(0)}%',
                    titleStyle: GoogleFonts.sora(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(categories.length, (index) {
            final entry = categories[index];
            final color = _categoryIconColor(entry.key);
            final bgColor = _categoryBgColor(entry.key);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _categoryIcon(entry.key),
                      color: color,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                  ),
                  Text(
                    isVisible ? formatter.format(entry.value) : r'R$ ••••',
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  double _getMaxY(AnalyticsData analytics) {
    final max = analytics.totalIncome > analytics.totalExpenses
        ? analytics.totalIncome
        : analytics.totalExpenses;
    return max > 0 ? max * 1.2 : 100;
  }

  Color _categoryBgColor(String category) {
    switch (category) {
      case 'Alimentação':
        return const Color(0xFFFEF3C7);
      case 'Transporte':
        return const Color(0xFFDBEAFE);
      case 'Lazer':
        return const Color(0xFFF3E8FF);
      case 'Saúde':
        return const Color(0xFFFEE2E2);
      case 'Educação':
        return const Color(0xFFFAE8FF);
      case 'Salário':
        return const Color(0xFFD1FAE5);
      case 'Moradia':
        return const Color(0xFFCCFBF1);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _categoryIconColor(String category) {
    switch (category) {
      case 'Alimentação':
        return const Color(0xFFD97706);
      case 'Transporte':
        return const Color(0xFF2563EB);
      case 'Lazer':
        return const Color(0xFF9333EA);
      case 'Saúde':
        return const Color(0xFFDC2626);
      case 'Educação':
        return const Color(0xFFC084FC);
      case 'Salário':
        return const Color(0xFF059669);
      case 'Moradia':
        return const Color(0xFF0D9488);
      default:
        return const Color(0xFF64748B);
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
