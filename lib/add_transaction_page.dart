import 'package:flutter/material.dart';
import '../data.dart';

class AddTransactionPage extends StatefulWidget {
  final int accountId;
  const AddTransactionPage({super.key, required this.accountId});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  String type = 'وارد';
  final amountCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();

  void _save() {
    final amt = double.tryParse(amountCtrl.text);
    if (amt == null || categoryCtrl.text.isEmpty) return;

    transactions.add({
      'id': transactionIdCounter++,
      'accountId': widget.accountId,
      'type': type,
      'amount': amt,
      'category': categoryCtrl.text,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة عملية")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: type,
              items: ['وارد', 'صادر'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => type = v!),
            ),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "المبلغ")),
            TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: "التصنيف")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text("حفظ")),
          ],
        ),
      ),
    );
  }
}
