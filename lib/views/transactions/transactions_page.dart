import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/arabic_pdf_service.dart';
import '../../../data.dart';
import '../../models/account.dart';
import '../../services/theme_provider.dart';
import 'add_transaction_page.dart';
import 'edit_transaction_dialog.dart';


class TransactionsPage extends StatefulWidget {
  final Account account; // الحساب المراد عرض عملياته
  const TransactionsPage({super.key, required this.account});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<Map<String, dynamic>> get accountTxs =>
      transactions.where((tx) => tx['accountId'] == widget.account.id).toList();

  double get balance {
    double sum = 0;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    for (var tx in accountTxs) {
      sum += tx['type'] == themeProvider.incomeLabel ? tx['amount'] : -tx['amount'];
    }
    return sum;
  }


  void _refresh() => setState(() {});


  void _editTransaction(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => EditTransactionDialog(
        transaction: transaction,
        onSaved: _refresh, // تحديث الواجهة بعد الحفظ
      ),
    );
  }

  /**
   * توليد تقرير PDF لعمليات الحساب
   */
  Future<void> _generatePDF() async {
    try {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await ArabicPDFService.generateArabicReport(widget.account.id!, themeProvider, accountName: widget.account.name);
      
      // عرض رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء تقرير PDF عربي بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // عرض رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إنشاء التقرير: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // شريط التطبيق العلوي مع اسم الحساب وزر تصدير PDF
      appBar: AppBar(
        title: Text(widget.account.name),
        actions: [
          // زر تصدير PDF
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePDF,
            tooltip: 'تصدير PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          // رمز الحساب مع تأثير Hero للانتقال السلس
          Hero(
            tag: 'accountHero${widget.account.id}',
            child: CircleAvatar(
              radius: 50,
              child: Text(
                widget.account.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          // عرض الرصيد الحالي للحساب
          Text(
            "الرصيد الحالي: $balance",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          // قائمة العمليات المالية
          Expanded(
            child: ListView.builder(
              itemCount: accountTxs.length,
              itemBuilder: (_, i) {
                final tx = accountTxs[i];
                final date = tx['date'] ?? DateTime.now();
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    // أيقونة نوع العملية (وارد أو صادر)
                    leading: Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        final isIncome = tx['type'] == themeProvider.incomeLabel;
                        return Icon(
                          isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isIncome ? Colors.green : Colors.red,
                        );
                      },
                    ),
                    
                    // عنوان العملية (النوع والمبلغ)
                    title: Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        final isIncome = tx['type'] == themeProvider.incomeLabel;
                        return Text(
                          "${tx['type']} - ${isIncome ? '+' : '-'}${tx['amount']}",
                          style: TextStyle(
                            color: isIncome ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    
                    // تفاصيل إضافية (التصنيف والتاريخ)
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tx['category']), // تصنيف العملية
                        Text(
                          '${date.day}/${date.month}/${date.year}', // تاريخ العملية
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    // أيقونة التعديل
                    trailing: const Icon(Icons.edit, color: Colors.blue),
                    
                    // فتح نافذة التعديل عند النقر
                    onTap: () => _editTransaction(tx),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // زر إضافة عملية جديدة
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // الانتقال لصفحة إضافة عملية جديدة
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionPage(accountId: widget.account.id!),
            ),
          );
          // تحديث الواجهة بعد العودة من صفحة الإضافة
          _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
