import 'package:flutter/material.dart';
import '../../data.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  void _addCategory() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("إضافة تصنيف"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "ادخل اسم التصنيف"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    categories.add({
                      'id': categoryIdCounter++,
                      'name': controller.text,
                      'enabled': true,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("حفظ"),
            ),
          ],
        );
      },
    );
  }

  void _toggleCategory(int index, bool value) {
    setState(() {
      categories[index]['enabled'] = value;
    });

    // إرسال إشارة أن البيانات تغيرت
    _notifyParent();
  }

  void _notifyParent() {
    // هذا سيعيد بناء الصفحة الرئيسية عند العودة
    if (mounted) {
      // يمكنك إضافة أي منطق إضافي هنا إذا needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("التصنيفات")),
      body: categories.isEmpty
          ? const Center(child: Text("لا توجد تصنيفات بعد"))
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return ListTile(
                  leading: Icon(
                    Icons.label,
                    color: cat['enabled'] ? Colors.blue : Colors.grey,
                  ),
                  title: Text(
                    cat['name'],
                    style: TextStyle(
                      color: cat['enabled'] ? Colors.black : Colors.grey,
                    ),
                  ),
                  trailing: Switch(
                    value: cat['enabled'],
                    activeColor: Colors.green,
                    onChanged: (val) => _toggleCategory(index, val),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCategory,
        icon: const Icon(Icons.add),
        label: const Text("إضافة تصنيف"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
