// import '../models/transaction_entry.dart';
// import '../services/database_service.dart';

// class TransactionsController {
//   final _db = DatabaseService.I;

//   Future<int> add({
//     required int accountId,
//     required String type, // 'وارد' أو 'صادر'
//     required double amount,
//     int? categoryId,
//     String? note,
//   }) {
//     return _db.addTransaction(
//       TransactionEntry(
//         accountId: accountId,
//         type: type,
//         amount: amount,
//         details: note,
//       ),
//     );
//   }

//   Future<List<TransactionEntry>> byAccount(int accountId) =>
//       _db.getAccountTransactions(accountId);

//   Future<int> remove(int id) => _db.deleteTransaction(id);
// }
