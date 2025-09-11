List<Map<String, dynamic>> accounts = [];
int accountIdCounter = 1;

// القوائم لتخزين العمليات مؤقتًا
List<Map<String, dynamic>> transactions = [];
int transactionIdCounter = 1;
// الحسابات


// التصنيفات
List<Map<String, dynamic>> categories = [
  {'id': 1, 'name': 'شخصي', 'enabled': true},
  {'id': 2, 'name': 'عمل', 'enabled': true},
  {'id': 3, 'name': 'مدخرات', 'enabled': true},
];
int categoryIdCounter = 4;