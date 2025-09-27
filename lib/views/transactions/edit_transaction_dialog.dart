import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data.dart';
import '../../services/theme_provider.dart';

class EditTransactionDialog extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onSaved;

  const EditTransactionDialog({
    super.key,
    required this.transaction,
    required this.onSaved,
  });

  @override
  State<EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  late String type;
  late TextEditingController amountCtrl;
  late TextEditingController categoryCtrl;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    type = widget.transaction['type'];
    amountCtrl = TextEditingController(text: widget.transaction['amount'].toString());
    categoryCtrl = TextEditingController(text: widget.transaction['category']);
    selectedDate = widget.transaction['date'] ?? DateTime.now();
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    categoryCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    final amt = double.tryParse(amountCtrl.text);
    if (amt == null || categoryCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول بشكل صحيح')),
      );
      return;
    }

    // Find and update the transaction in the global list
    final index = transactions.indexWhere((tx) => tx['id'] == widget.transaction['id']);
    if (index != -1) {
      transactions[index] = {
        ...transactions[index],
        'type': type,
        'amount': amt,
        'category': categoryCtrl.text,
        'date': selectedDate,
      };
    }

    // Save transactions to persistent storage
    await DataPersistence.saveTransactions();

    widget.onSaved();
    Navigator.pop(context);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعديل العملية'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Transaction Type Dropdown - قائمة اختيار نوع العملية
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                // التأكد من أن نوع العملية موجود في الخيارات الحالية
                final availableTypes = [themeProvider.incomeLabel, themeProvider.expenseLabel];
                if (!availableTypes.contains(type)) {
                  // إذا لم يكن النوع موجوداً، استخدم القيمة الافتراضية
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      type = themeProvider.incomeLabel;
                    });
                  });
                }
                
                return DropdownButtonFormField<String>(
                  value: availableTypes.contains(type) ? type : themeProvider.incomeLabel,
                  decoration: const InputDecoration(
                    labelText: 'نوع العملية',
                    border: OutlineInputBorder(),
                  ),
                  items: availableTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => type = v!),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Amount Field
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            
            // Category Field
            TextField(
              controller: categoryCtrl,
              decoration: const InputDecoration(
                labelText: 'التفاصيل',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 16),
            
            // Date Picker
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'تاريخ العملية',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
