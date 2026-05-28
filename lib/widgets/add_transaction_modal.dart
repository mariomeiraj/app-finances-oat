import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:app_finances_oat/models/transaction_model.dart';
import 'package:app_finances_oat/core/validators/form_validators.dart';
import 'package:app_finances_oat/widgets/custom_text_field.dart';
import 'package:app_finances_oat/widgets/primary_button.dart';

class AddTransactionModal extends StatefulWidget {
  final void Function(TransactionModel) onSave;
  final TransactionModel? existingTransaction;
  final int userId;

  const AddTransactionModal({
    super.key,
    required this.onSave,
    this.existingTransaction,
    required this.userId,
  });

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  TransactionType _selectedType = TransactionType.expense;
  String _selectedCategory = 'Outros';
  DateTime _selectedDate = DateTime.now();

  static const _categories = [
    'Alimentação',
    'Transporte',
    'Lazer',
    'Saúde',
    'Educação',
    'Salário',
    'Moradia',
    'Outros',
  ];

  static const _greenAccent = Color(0xFF00C853);

  bool get _isEditing => widget.existingTransaction != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();

    final existing = widget.existingTransaction;
    if (existing != null) {
      _titleController.text = existing.title;
      _amountController.text =
          existing.amount.toStringAsFixed(2).replaceAll('.', ',');
      _selectedType = existing.type;
      _selectedCategory = existing.category;
      _selectedDate = existing.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: _greenAccent,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final amountText =
        _amountController.text.replaceAll('.', '').replaceAll(',', '.');
    final amount = double.parse(amountText);

    final transaction = TransactionModel(
      id: widget.existingTransaction?.id,
      userId: widget.userId,
      title: _titleController.text.trim(),
      amount: amount,
      type: _selectedType,
      category: _selectedCategory,
      date: _selectedDate,
    );

    widget.onSave(transaction);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEditing ? 'Editar transação' : 'Adicionar transação',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Título',
                hint: 'Ex: Mercado, Salário...',
                controller: _titleController,
                validator: FormValidators.validateTitle,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Valor',
                hint: 'Ex: 150,00',
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 12, top: 14),
                  child: Text(
                    'R\$',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                validator: FormValidators.validateAmount,
              ),
              const SizedBox(height: 16),
              _buildTypeToggle(),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: _greenAccent, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: _greenAccent,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Salvar',
                onPressed: _handleSave,
                icon: Icons.check,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return SegmentedButton<TransactionType>(
      segments: const [
        ButtonSegment(
          value: TransactionType.income,
          label: Text('Receita'),
          icon: Icon(Icons.arrow_upward, size: 18),
        ),
        ButtonSegment(
          value: TransactionType.expense,
          label: Text('Despesa'),
          icon: Icon(Icons.arrow_downward, size: 18),
        ),
      ],
      selected: {_selectedType},
      onSelectionChanged: (selected) {
        setState(() => _selectedType = selected.first);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _selectedType == TransactionType.income
                ? _greenAccent.withValues(alpha: 0.12)
                : Colors.redAccent.withValues(alpha: 0.12);
          }
          return Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _selectedType == TransactionType.income
                ? _greenAccent
                : Colors.redAccent;
          }
          return Colors.grey.shade600;
        }),
        side: WidgetStateProperty.all(
          BorderSide(color: Colors.grey.shade300),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
