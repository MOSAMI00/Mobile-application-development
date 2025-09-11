import 'package:flutter/material.dart';
import 'package:test1/models/account.dart';
import '../../../data.dart';
import '../../controllers/accounts_controller.dart';
import '../transactions/transactions_page.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final PageController _pageController = PageController();
  final _controller = AccountsController();
  int _currentIndex = 0;

  List<String> get _categories {
    try {
      // تصفية التصنيفات المعطلة فقط
      final enabledCats = categories
          .where((cat) => cat['enabled'] == true)
          .toList();
      final cats = enabledCats.map((c) => c['name'] as String).toList();
      return ["الكل", ...cats];
    } catch (e) {
      return ["الكل"]; // fallback إذا حدث خطأ
    }
  }

  Future<List<Account>> _getAccountsForCategory(int index) async {
    try {
      if (index == 0) {
        return await _controller.listAcounts();
      } // إرجاع جميع الحسابات إذا كان "الكل" محددًا
      if (_categories.length <= index) return []; // منع تجاوز الحدود

      return await _controller.byCategory(index);
    } catch (e) {
      return []; // إرجاع قائمة فارغة إذا حدث خطأ
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeCategories = _categories;

    return Scaffold(
      body: Column(
        children: [
          // Accounts Header - مع التحقق من الحدود
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Text(
                  safeCategories.isNotEmpty &&
                          _currentIndex < safeCategories.length
                      ? safeCategories[_currentIndex]
                      : "لا توجد تصنيفات",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                FutureBuilder<List<Account>>(
                  future: _getAccountsForCategory(_currentIndex),
                  builder: (context, snapshot) {
                    final count = snapshot.hasData ? snapshot.data!.length : 0;
                    return Text(
                      "$count حساب",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // PageView for Accounts - مع التحقق من الحدود
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  // التأكد من أن الفهرس ضمن الحدود
                  _currentIndex = index < safeCategories.length ? index : 0;
                });
              },
              itemCount: safeCategories.length,
              itemBuilder: (context, index) {
                return FutureBuilder<List<Account>>(
                  future: _getAccountsForCategory(index),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final accountsList = snapshot.data!;
                    if (accountsList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              index == 0
                                  ? "لا توجد حسابات"
                                  : "لا توجد حسابات في هذا التصنيف",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: accountsList.length,
                      itemBuilder: (context, i) {
                        final account = accountsList[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  account.name.isNotEmpty
                                      ? account.name[0].toUpperCase()
                                      : "?",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              account.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              "${account.categoryId}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Colors.grey[400],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TransactionsPage(account: account),
                                ),
                              ).then((_) => setState(() {}));
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
