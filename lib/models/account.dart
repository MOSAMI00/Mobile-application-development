class Account {
  final int? id;
  final String name;
  final double balance;
  final int categoryId;

  Account({
    this.id,
    required this.name,
    this.balance = 0.0,
    required this.categoryId,
  });

  factory Account.fromMap(Map<String, dynamic> map) => Account(
    id: map['id'] as int?,
    name: map['name'] as String,
    balance: map['balance'] as double,
    categoryId: map['category_id'] as int,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'balance': balance,
    'category_id': categoryId,
  };
}
