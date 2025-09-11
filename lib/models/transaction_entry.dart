class TransactionEntry {
  final int? id;
  final int accountId;
  final String type; // 'وارد' أو 'صادر'
  final double amount;
  final String? details; // تفاصيل إضافية
  final DateTime createdAt;

  TransactionEntry({
    this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    this.details,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TransactionEntry.fromMap(Map<String, dynamic> map) =>
      TransactionEntry(
        id: map['id'] as int?,
        accountId: map['account_id'] as int,
        type: map['type'] as String,
        amount: (map['amount'] as num).toDouble(),
        details: map['details'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['created_at'] as int,
        ),
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'account_id': accountId,
    'type': type,
    'amount': amount,
    'details': details,
    'created_at': createdAt.millisecondsSinceEpoch,
  };
}
