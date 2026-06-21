class FinancialItem {
  final String id;
  final String description;
  final int quantity;
  final double unitPriceEgp;
  final double lineTotal;
  final bool coveredByInsurance;
  final String paymentMethod;
  final DateTime? paidAt;

  FinancialItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPriceEgp,
    required this.lineTotal,
    required this.coveredByInsurance,
    required this.paymentMethod,
    required this.paidAt,
  });

  factory FinancialItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    return FinancialItem(
      id: json['id']?.toString() ?? '',
      description: (json['item_description'] ?? '').toString(),
      quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      unitPriceEgp: parseDouble(json['unit_price_egp']),
      lineTotal: parseDouble(json['line_total']),
      coveredByInsurance:
          (json['covered_by_insurance'] ?? false) as bool? ?? false,
      paymentMethod: (json['payment_method'] ?? '').toString(),
      paidAt: DateTime.tryParse((json['paid_at'] ?? '').toString()),
    );
  }
}

class FinancialTotals {
  final double gross;
  final double coveredByInsurance;
  final double patientResponsibility;
  final double paid;
  final double outstanding;

  FinancialTotals({
    required this.gross,
    required this.coveredByInsurance,
    required this.patientResponsibility,
    required this.paid,
    required this.outstanding,
  });

  factory FinancialTotals.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    return FinancialTotals(
      gross: parseDouble(json['gross']),
      coveredByInsurance: parseDouble(json['covered_by_insurance']),
      patientResponsibility: parseDouble(json['patient_responsibility']),
      paid: parseDouble(json['paid']),
      outstanding: parseDouble(json['outstanding']),
    );
  }
}

class FinancialFile {
  final String ticketNo;
  final List<FinancialItem> items;
  final FinancialTotals totals;

  FinancialFile({
    required this.ticketNo,
    required this.items,
    required this.totals,
  });

  factory FinancialFile.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    final items = <FinancialItem>[];
    if (itemsJson is List) {
      for (final item in itemsJson.whereType<Map<String, dynamic>>()) {
        items.add(FinancialItem.fromJson(item));
      }
    }

    final totalsJson = json['totals'];
    return FinancialFile(
      ticketNo: (json['ticket_no'] ?? '').toString(),
      items: items,
      totals: totalsJson is Map<String, dynamic>
          ? FinancialTotals.fromJson(totalsJson)
          : FinancialTotals(
              gross: 0.0,
              coveredByInsurance: 0.0,
              patientResponsibility: 0.0,
              paid: 0.0,
              outstanding: 0.0,
            ),
    );
  }
}
