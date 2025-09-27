import 'package:flutter/material.dart';
import '../../data.dart';
import '../../models/account.dart';
import '../../services/database_service.dart';


/**
 * نافذة تعديل الحساب - تعمل تلقائياً وفورياً
 * إصلاح شامل للحفظ والحذف
 */
class EditAccountDialog extends StatefulWidget {
  final Account account;
  final VoidCallback onSaved;

  const EditAccountDialog({
    Key? key,
    required this.account,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<EditAccountDialog> createState() => _EditAccountDialogState();
}

class _EditAccountDialogState extends State<EditAccountDialog> {
  late TextEditingController _nameController;
  late int _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.name);
    _selectedCategoryId = widget.account.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /**
   * حفظ التغييرات تلقائياً وفورياً - مُحدث ومُصحح
   */
  void _saveChanges() async {
    // التحقق من صحة البيانات
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال اسم الحساب'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print('بدء حفظ تعديل الحساب - ID: ${widget.account.id}');
      print('الاسم الجديد: "${_nameController.text.trim()}"');
      print('التصنيف الجديد: $_selectedCategoryId');
      // تحديث في قاعدة البيانات بدل القوائم المؤقتة لضمان انعكاسه في الشاشة
      
      final newName = _nameController.text.trim();
      final newCategoryId = _selectedCategoryId;

      // تحديث الكائن في الذاكرة لعرض المعلومات في نافذة الحوار فوراً
      widget.account.name = newName;
      widget.account.categoryId = newCategoryId;

      // حفظ في قاعدة البيانات (SQLite)
      await DatabaseService.I.updateAccount(
        Account(
          id: widget.account.id,
          name: newName,
          balance: widget.account.balance,
          categoryId: newCategoryId,
        ),
      );
      print('تم تحديث الحساب في قاعدة البيانات');
      
      // تحديث الواجهة فوراً قبل الإغلاق
      widget.onSaved();
      print('تم استدعاء onSaved لتحديث الواجهة');
      
      // إغلاق النافذة مع إرجاع قيمة النجاح
      if (mounted) {
        Navigator.pop(context, true);
        
        // عرض رسالة نجاح بعد الإغلاق
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ "$newName" بنجاح'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('خطأ في حفظ البيانات: $e');
      // عرض رسالة خطأ في حالة فشل الحفظ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ البيانات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /**
   * حذف الحساب تلقائياً وفورياً مع تأكيد بسيط
   */
  void _deleteAccount() async {
    // عرض نافذة تأكيد الحذف
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الحساب "${widget.account.name}"؟\nسيتم حذف جميع العمليات المرتبطة به.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        print('بدء حذف الحساب - ID: ${widget.account.id}');

        // حذف من قاعدة البيانات
        if (widget.account.id != null) {
          await DatabaseService.I.deleteAccount(widget.account.id!);
        }

        // مزامنة القوائم المؤقتة إن وُجدت (للاستمرارية مع الشاشات القديمة)
        accounts.removeWhere((acc) => acc['id'] == widget.account.id);
        transactions.removeWhere((tx) => tx['accountId'] == widget.account.id);
        
        // إغلاق النافذة مع إرجاع قيمة النجاح
        if (mounted) {
          Navigator.pop(context, true); // إرجاع true للإشارة للنجاح
        }
        
        // تحديث الواجهة بقوة
        widget.onSaved();
        
        // عرض رسالة نجاح
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الحساب نهائياً'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // عرض رسالة خطأ في حالة فشل الحذف
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في حذف الحساب: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _getCategoryName(int categoryId) {
    final category = categories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => {'name': 'غير محدد'},
    );
    return category['name'] ?? 'غير محدد';
  }
  
  /**
   * حساب الرصيد الحقيقي من العمليات الفعلية - محسن
   */
  double _calculateRealBalance() {
    try {
      final accountTxs = transactions.where((tx) => tx['accountId'] == widget.account.id).toList();
      double balance = 0.0;
      
      print('عدد العمليات للحساب ${widget.account.id}: ${accountTxs.length}');
      
      for (var tx in accountTxs) {
        final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
        final type = tx['type']?.toString() ?? '';
        
        print('عملية: $type -مبلغ: $amount');
        
        // تحديد نوع العملية بطريقة أوسع
        if (type.contains('وارد') || type.contains('دخل') || type.contains('إيداع') || 
            type.contains('income') || type.contains('deposit') || type.contains('+')) {
          balance += amount;
          print('إضافة: +$amount');
        } else {
          balance -= amount; // اعتبار أي عملية أخرى صادرة
          print('خصم: -$amount');
        }
      }
      
      print('الرصيد النهائي: $balance');
      return balance;
    } catch (e) {
      print('خطأ في حساب الرصيد: $e');
      return 0.0;
    }
  }
  
  /**
   * حساب عدد العمليات للحساب
   */
  int _getTransactionCount() {
    try {
      return transactions.where((tx) => tx['accountId'] == widget.account.id).length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعديل الحساب'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // حقل اسم الحساب
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الحساب',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // اختيار التصنيف
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'التصنيف',
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category['id'] as int,
                  child: Text(category['name'] as String),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            // معلومات الحساب مع حساب الرصيد الحقيقي
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الرصيد الحالي:${_calculateRealBalance().toStringAsFixed(2)} ريال'),
                  const SizedBox(height: 4),
                  Text('التصنيف: ${_getCategoryName(_selectedCategoryId)}'),
                  const SizedBox(height: 4),
                  Text('عدد العمليات: ${_getTransactionCount()}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // زر الحذف
        TextButton(
          onPressed: _deleteAccount,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('حذف الحساب'),
        ),
        
        // زر الإلغاء
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        
        // زر الحفظ
        ElevatedButton(
          onPressed: _saveChanges,
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
