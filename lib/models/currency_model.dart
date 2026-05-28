class CurrencyModel {
  final String code;
  final String name;
  final double buyPrice;
  final double sellPrice;
  final double variation;
  final DateTime updatedAt;

  const CurrencyModel({
    required this.code,
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    required this.variation,
    required this.updatedAt,
  });

  factory CurrencyModel.fromMap(Map<String, dynamic> map) {
    return CurrencyModel(
      code: map['code'] as String,
      name: map['name'] as String,
      buyPrice: (map['bid'] as num?)?.toDouble() ?? 0.0,
      sellPrice: (map['ask'] as num?)?.toDouble() ?? 0.0,
      variation: (map['pctChange'] as num?)?.toDouble() ?? 0.0,
      updatedAt: DateTime.tryParse(map['create_date'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
