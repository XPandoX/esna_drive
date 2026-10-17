enum TransactionType { topUp, commissionDeduction, commissionRefund }
enum TransactionStatus { pending, completed, rejected }

class WalletTransaction {
  final String id;
  final TransactionType type;
  final double amount;
  final DateTime timestamp;
  final String description;
  final String paymentMethod; // 'فوري (Fawry)', 'فودافون كاش', 'إنستا باي'
  final String? fawryRefCode;
  final TransactionStatus status;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.timestamp,
    required this.description,
    required this.paymentMethod,
    this.fawryRefCode,
    this.status = TransactionStatus.completed,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'timestamp': timestamp.toIso8601String(),
        'description': description,
        'paymentMethod': paymentMethod,
        'fawryRefCode': fawryRefCode,
        'status': status.name,
      };

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => WalletTransaction(
        id: json['id'],
        type: TransactionType.values.firstWhere((e) => e.name == json['type']),
        amount: (json['amount'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp']),
        description: json['description'],
        paymentMethod: json['paymentMethod'],
        fawryRefCode: json['fawryRefCode'],
        status: TransactionStatus.values.firstWhere((e) => e.name == json['status']),
      );
}
