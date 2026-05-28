import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_finances_oat/theme/app_theme.dart';
import 'package:app_finances_oat/viewmodels/currency_viewmodel.dart';
import 'package:app_finances_oat/models/currency_model.dart';

class CurrencyView extends ConsumerStatefulWidget {
  const CurrencyView({super.key});

  @override
  ConsumerState<CurrencyView> createState() => _CurrencyViewState();
}

class _CurrencyViewState extends ConsumerState<CurrencyView> {
  final _brlController = TextEditingController(text: '1.00');
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currencyViewModelProvider.notifier).fetchRates();
    });
    // Atualiza o contador de 5 minutos exibido no botão a cada segundo
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _brlController.dispose();
    super.dispose();
  }

  IconData _getCurrencyIcon(String code) {
    switch (code) {
      case 'USD':
        return Icons.attach_money;
      case 'EUR':
        return Icons.euro;
      case 'BTC':
        return Icons.currency_bitcoin;
      default:
        return Icons.monetization_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currencyViewModelProvider);
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

    final lastUpdated = state.lastUpdated;
    int secondsRemaining = 0;
    if (lastUpdated != null) {
      final nextAllowedTime = lastUpdated.add(const Duration(minutes: 5));
      final difference = nextAllowedTime.difference(DateTime.now());
      if (difference.inSeconds > 0) {
        secondsRemaining = difference.inSeconds;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cotações')),
      body: _buildBody(state, formatter, dateFormatter, secondsRemaining),
    );
  }

  Widget _buildBody(
    dynamic state,
    NumberFormat formatter,
    DateFormat dateFormatter,
    int secondsRemaining,
  ) {
    if (state.isLoading && state.currencies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.currencies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(currencyViewModelProvider.notifier).fetchRates(),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final currencies = state.currencies as List<CurrencyModel>;

    return RefreshIndicator(
      onRefresh: () async {
        if (secondsRemaining > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Aguarde ${secondsRemaining ~/ 60}m e ${secondsRemaining % 60}s para atualizar novamente.',
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
          return;
        }
        await ref.read(currencyViewModelProvider.notifier).fetchRates();
      },
      color: AppTheme.primaryGreen,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (currencies.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Última atualização:',
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                    Text(
                      dateFormatter.format(state.lastUpdated ?? currencies.first.updatedAt),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: secondsRemaining > 0
                      ? null
                      : () => ref.read(currencyViewModelProvider.notifier).fetchRates(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(
                    secondsRemaining > 0
                        ? 'Bloqueado (${secondsRemaining ~/ 60}:${(secondsRemaining % 60).toString().padLeft(2, '0')})'
                        : 'Recarregar',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    disabledForegroundColor: Colors.grey[400],
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          ...currencies.map((currency) =>
              _buildCurrencyCard(currency, formatter)),
          const SizedBox(height: 24),
          _buildConverterSection(currencies, formatter),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard(CurrencyModel currency, NumberFormat formatter) {
    final isPositive = currency.variation >= 0;
    final variationColor = isPositive ? AppTheme.incomeGreen : AppTheme.expenseRed;
    final variationIcon =
        isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCurrencyIcon(currency.code),
                color: AppTheme.primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency.code,
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    currency.name,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Compra: ${formatter.format(currency.buyPrice)}',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Venda: ${formatter.format(currency.sellPrice)}',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(variationIcon, size: 14, color: variationColor),
                    const SizedBox(width: 2),
                    Text(
                      '${currency.variation.toStringAsFixed(2)}%',
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: variationColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConverterSection(
    List<CurrencyModel> currencies,
    NumberFormat formatter,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simulador de Câmbio',
              style: GoogleFonts.sora(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _brlController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Valor em Real (BRL)',
                prefixIcon: const Icon(Icons.attach_money_rounded, size: 20),
                prefixText: 'R\$ ',
                labelStyle: GoogleFonts.inter(color: AppTheme.textMedium),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),
            ...currencies.map((currency) {
              final brl = double.tryParse(
                      _brlController.text.replaceAll(',', '.')) ??
                  0;
              final converted =
                  currency.buyPrice > 0 ? brl / currency.buyPrice : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getCurrencyIcon(currency.code),
                            size: 14,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          currency.code,
                          style: GoogleFonts.sora(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    Text(
                      converted.toStringAsFixed(
                          currency.code == 'BTC' ? 8 : 2),
                      style: GoogleFonts.sora(
                        fontSize: 14,
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
      ),
    );
  }
}
