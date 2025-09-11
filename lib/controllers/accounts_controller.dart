import '../models/account.dart';
import '../services/database_service.dart';

class AccountsController {
  final _db = DatabaseService.I;

  Future<List<Account>> listAcounts() => _db.getAccounts();

  Future<int> add(String name, int category_id) =>
      _db.createAccount(Account(name: name, categoryId: category_id));

  // Future<int> rename(Account a, String newName) =>
  //     _db.updateAccount(Account(id: a.id, name: newName));

  Future<int> remove(int id) => _db.deleteAccount(id);

  Future<double> balance(int accountId) =>
      _db.getAccount(accountId).then((a) => a?.balance ?? 0.0);

  Future<List<Account>> byCategory(int categoryId) =>
      _db.getAccountsByCategory(categoryId);
}
