import 'package:flutter/material.dart';
import '../../../data.dart';
import '../../controllers/accounts_controller.dart';

class AddAccountPage extends StatefulWidget {
  const AddAccountPage({super.key});

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  final _nameController = TextEditingController();
  final _controller = AccountsController();
  int? _selectedCategoryId;

  void _saveAccount() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("يرجى إدخال اسم الحساب")));
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("يرجى اختيار التصنيف")));
      return;
    }

    // Check if categories is empty
    if (categories.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("يرجى إضافة تصنيفات أولاً")));
      return;
    }
    // التحقق من وجود تصنيفات مفعلة
    final enabledCategories = categories
        .where((cat) => cat['enabled'] == true)
        .toList();
    if (enabledCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لا توجد تصنيفات مفعلة، يرجى تفعيل تصنيف أولاً"),
        ),
      );
      return;
    }

    // البحث عن التصنيف المحدد والتأكد من أنه مفعل
    final category = categories.firstWhere(
      (cat) => cat['id'] == _selectedCategoryId && cat['enabled'] == true,
      orElse: () => {},
    );

    if (category.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("التصنيف المحدد غير مفعل")));
      return;
    }

    await _controller.add(_nameController.text.trim(), _selectedCategoryId!);

    // setState(() {
    //   accounts.add({
    //     'id': accountIdCounter++,
    //     'name': _nameController.text,
    //     'categoryId': _selectedCategoryId,
    //     'category': category['name'],
    //     'balance': 0.0,
    //   });
    // });

    // Navigate back first
    Navigator.pop(context);

    // Then trigger rebuild in the parent page if needed
    // This will be handled by the natural navigation flow
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة حساب")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "اسم الحساب",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: "اختر التصنيف",
                border: OutlineInputBorder(),
              ),
              items: categories
                  .where(
                    (cat) => cat['enabled'] == true,
                  ) // فقط التصنيفات المفعلة
                  .map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat['id'],
                      child: Text(cat['name']),
                    );
                  })
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategoryId = val;
                });
              },
              value: _selectedCategoryId,
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveAccount,
                icon: const Icon(Icons.save),
                label: const Text("حفظ الحساب"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
