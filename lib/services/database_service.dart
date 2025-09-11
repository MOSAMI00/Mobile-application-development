import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/transaction_entry.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService _instance = DatabaseService._();
  static DatabaseService get I => _instance;

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'ledger.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // accounts
    await db.execute('''
      CREATE TABLE accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0.0,
        category_id INTEGER,
        FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE SET NULL
      );
    ''');

    // categories
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 1
      );
    ''');

    // // transactions
    // await db.execute('''
    //   CREATE TABLE transactions(
    //     id INTEGER PRIMARY KEY AUTOINCREMENT,
    //     account_id INTEGER NOT NULL,
    //     type TEXT NOT NULL CHECK (type IN ('وارد','صادر')),
    //     amount REAL NOT NULL,
    //     details TEXT,
    //     created_at INTEGER NOT NULL,
    //     FOREIGN KEY(account_id) REFERENCES accounts(id) ON DELETE CASCADE,
    //   );
    // ''');

    // Seed default categories
    final batch = db.batch();
    for (final name in const ['شخصي', 'عمل', 'مدخرات']) {
      batch.insert('categories', {'name': name, 'enabled': 1});
    }
    await batch.commit(noResult: true);
  }

  // ============ Accounts ============
  Future<int> createAccount(Account a) async {
    final database = await db;
    return database.insert('accounts', a.toMap());
  }

  Future<List<Account>> getAccounts() async {
    final database = await db;
    final rows = await database.query('accounts', orderBy: 'id DESC');
    return rows.map(Account.fromMap).toList();
  }

  Future<Account?> getAccount(int id) async {
    final database = await db;
    final rows = await database.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Account.fromMap(rows.first);
  }

  Future<int> updateAccount(Account a) async {
    final database = await db;
    return database.update(
      'accounts',
      a.toMap(),
      where: 'id = ?',
      whereArgs: [a.id],
    );
  }

  Future<int> deleteAccount(int id) async {
    final database = await db;
    return database.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Account>> getAccountsByCategory(int categoryId) async {
    final database = await db;
    final rows = await database.query(
      'accounts',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'id DESC',
    );
    return rows.map(Account.fromMap).toList();
  }

  // ============ Categories ============
  Future<int> createCategory(CategoryModel c) async {
    final database = await db;
    return database.insert('categories', c.toMap()..remove('id'));
  }

  Future<List<CategoryModel>> getCategories({bool? enabled}) async {
    final database = await db;
    final rows = await database.query('categories', orderBy: 'id DESC');
    return rows.map(CategoryModel.fromMap).toList();
  }

  // // ============ Transactions ============
  // Future<int> addTransaction(TransactionEntry t) async {
  //   final database = await db;
  //   return database.insert('transactions', t.toMap()..remove('id'));
  // }

  // Future<List<TransactionEntry>> getAccountTransactions(int accountId) async {
  //   final database = await db;
  //   final rows = await database.query(
  //     'transactions',
  //     where: 'account_id = ?',
  //     whereArgs: [accountId],
  //     orderBy: 'created_at DESC',
  //   );
  //   return rows.map(TransactionEntry.fromMap).toList();
  // }

  // Future<int> deleteTransaction(int id) async {
  //   final database = await db;
  //   return database.delete('transactions', where: 'id = ?', whereArgs: [id]);
  // }
}
