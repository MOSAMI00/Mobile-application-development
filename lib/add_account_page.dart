import 'package:flutter/material.dart';
import '../data.dart';

class AddAccountPage extends StatefulWidget {
  const AddAccountPage({super.key});

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  final controller = TextEditingController();

  void _save() {
    if (controller.text.isEmpty) return;
    accounts.add({'id': accountIdCounter++, 'name': controller.text});
    controller.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم إضافة الحساب')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة حساب")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "اسم الحساب"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text("حفظ")),
          ],
        ),
      ),
    );
  }
}
