import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data.dart';
import '../../services/theme_provider.dart';

class AddTransactionPage extends StatefulWidget {
  final int accountId;
  const AddTransactionPage({super.key, required this.accountId});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  String type = ''; // سيتم تهيئته في initState
  final amountCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // تهيئة نوع العملية بالتسمية المخصصة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      setState(() {
        type = themeProvider.incomeLabel; // استخدام التسمية المخصصة
      });
    });
  }

  void _save() async {
    final amt = double.tryParse(amountCtrl.text);
    if (amt == null || categoryCtrl.text.isEmpty) return;

    transactions.add({
      'id': transactionIdCounter++,
      'accountId': widget.accountId,
      'type': type, // استخدام التسمية المخصصة
      'amount': amt,
      'category': categoryCtrl.text,
      'date': selectedDate,
    });

    // حفظ العمليات في التخزين المحلي
    await DataPersistence.saveTransactions();

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // التأكد من أن نوع العملية مهيأ بشكل صحيح
    if (type.isEmpty) {
      type = themeProvider.incomeLabel;
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة عملية")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // قائمة اختيار نوع العملية بالتسميات المخصصة
            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(
                labelText: 'نوع العملية',
                border: OutlineInputBorder(),
              ),
              items: [
                themeProvider.incomeLabel,  // استخدام التسمية المخصصة
                themeProvider.expenseLabel, // استخدام التسمية المخصصة
              ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => type = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "المبلغ",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryCtrl,
              decoration: const InputDecoration(
                labelText: "التفاصيل",
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
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text("حفظ")),
          ],
        ),
      ),
    );
  }
}
