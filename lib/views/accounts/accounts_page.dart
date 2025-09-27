import 'package:flutter/material.dart';
import 'package:test1/models/account.dart';
import '../../../data.dart';
import '../../controllers/accounts_controller.dart';
import '../transactions/transactions_page.dart';
import 'edit_account_dialog.dart';

/**
 * صفحة عرض الحسابات
 * 
 * هذه الصفحة تعرض:
 * - جميع الحسابات مقسمة حسب التصنيفات
 * - إمكانية التنقل بين التصنيفات بالتمرير
 * - النقر على الحساب لعرض عملياته
 * - النقر المطول على الحساب لتعديل بياناته
 */

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final PageController _pageController = PageController(); // متحكم في صفحات التصنيفات
  final _controller = AccountsController(); // متحكم عمليات الحسابات
  int _currentIndex = 0; // فهرس التصنيف الحالي

  /**
   * الحصول على قائمة التصنيفات المفعلة
   * يتم إضافة "الكل" في البداية لعرض جميع الحسابات
   */
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

  /**
   * الحصول على الحسابات حسب التصنيف
   * إذا كان الفهرس 0 يتم إرجاع جميع الحسابات
   */
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

  /**
   * الحصول على اسم التصنيف من معرفه
   * يستخدم لعرض اسم التصنيف بدلاً من الرقم
   */
  String _getCategoryName(int categoryId) {
    try {
      final category = categories.firstWhere(
        (cat) => cat['id'] == categoryId,
        orElse: () => {'name': 'غير محدد'},
      );
      return category['name'] as String;
    } catch (e) {
      return 'غير محدد';
    }
  }

  /**
   * فتح نافذة تعديل بيانات الحساب - محدث ومصحح
   * يتم استدعاؤها عند النقر المطول على الحساب
   */
  void _editAccount(Account account) async {
    print('فتح نافذة تعديل الحساب: ${account.name} (ID: ${account.id})');
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditAccountDialog(
        account: account,
        onSaved: () {
          print('تم استدعاء onSaved - سيتم تحديث الواجهة');
          // إجبار إعادة تحميل البيانات بالقوة
          _forceRefresh();
        },
      ),
    );
    
    // تحديث إضافي بعد إغلاق النافذة
    if (result == true || result == null) {
      print('تحديث إضافي بعد إغلاق نافذة التعديل');
      _forceRefresh();
    }
  }
  
  /**
   * إجبار تحديث شامل للواجهة وإعادة تحميل البيانات من قاعدة البيانات
   */
  void _forceRefresh() async {
    print('إجبار تحديث شامل للواجهة وإعادة تحميل من قاعدة البيانات');
    
    // إعادة تحميل البيانات من قاعدة البيانات
    try {
      final dbAccounts = await _controller.listAcounts();
      print('تم تحميل ${dbAccounts.length} حساب من قاعدة البيانات');
      
      // تحديث القائمة المؤقتة للتوافق مع الشاشات الأخرى
      accounts.clear();
      for (var account in dbAccounts) {
        accounts.add({
          'id': account.id,
          'name': account.name,
          'balance': account.balance,
          'categoryId': account.categoryId,
        });
      }
      
      // حفظ التحديثات
      await DataPersistence.saveAccounts();
      print('تم مزامنة البيانات مع التخزين المحلي');
    } catch (e) {
      print('خطأ في إعادة تحميل البيانات: $e');
    }
    
    // إجبار إعادة بناء الواجهة
    if (mounted) {
      setState(() {
        _currentIndex = _currentIndex; // تحديث وهمي لإجبار rebuild
      });
    }
    
    // تأخير بسيط ثم تحديث إضافي
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {});
      }
    });
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
                          // عنصر قائمة الحساب مع دعم النقر العادي والمطول
                          child: GestureDetector(
                            // النقر العادي - فتح صفحة العمليات
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TransactionsPage(account: account),
                                ),
                              ).then((_) => setState(() {}));
                            },
                            // النقر المطول - فتح نافذة التعديل
                            onLongPress: () => _editAccount(account),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              // رمز الحساب (أول حرف من الاسم)
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
                              // اسم الحساب
                              title: Text(
                                account.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              // اسم التصنيف (بدلاً من الرقم)
                              subtitle: Text(
                                _getCategoryName(account.categoryId),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              // سهم لليمين للدلالة على إمكانية النقر
                              trailing: Icon(
                                Icons.chevron_right,
                                color: Colors.grey[400],
                              ),
                            ),
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
