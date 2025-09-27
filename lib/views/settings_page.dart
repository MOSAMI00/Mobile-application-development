import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/services/theme_provider.dart';



class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  final TextEditingController _incomeLabelController = TextEditingController();
  final TextEditingController _expenseLabelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // تهيئة قيم التسميات الحالية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      _incomeLabelController.text = themeProvider.incomeLabel;
      _expenseLabelController.text = themeProvider.expenseLabel;
    });
  }

  @override
  void dispose() {
    _incomeLabelController.dispose();
    _expenseLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Mode
          Card(
            child: ListTile(
              leading: const Icon(Icons.brightness_4),
              title: const Text('المظهر'),
              subtitle: Text(themeProvider.themeMode == ThemeMode.dark 
                  ? 'مظلم' 
                  : themeProvider.themeMode == ThemeMode.light 
                    ? 'فاتح' 
                    : 'تلقائي'),
              trailing: DropdownButton<ThemeMode>(
                value: themeProvider.themeMode,
                items: const [
                  DropdownMenuItem(value: ThemeMode.light, child: Text('فاتح')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('مظلم')),
                  DropdownMenuItem(value: ThemeMode.system, child: Text('تلقائي')),
                ],
                onChanged: (value) {
                  themeProvider.setThemeMode(value!);
                },
              ),
            ),
          ),

          // Primary Color
          Card(
            child: ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('اللون الأساسي'),
              subtitle: Wrap(
                spacing: 8,
                children: _colorOptions.map((color) {
                  return GestureDetector(
                    onTap: () {
                      themeProvider.setPrimaryColor(color);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: themeProvider.primaryColor.value == color.value
                              ? Colors.black
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // قسم تخصيص تسميات العمليات
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'تخصيص تسميات العمليات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'يمكنك تغيير أسماء العمليات لتناسب احتياجاتك',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  
                  // حقل تعديل تسمية العمليات الواردة
                  TextField(
                    controller: _incomeLabelController,
                    decoration: InputDecoration(
                      labelText: 'تسمية العمليات الواردة',
                      hintText: 'مثال: دخل، إيراد، ربح',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.arrow_downward, color: Colors.green),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () {
                          themeProvider.setIncomeLabel(_incomeLabelController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم حفظ تسمية العمليات الواردة'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // حقل تعديل تسمية العمليات الصادرة
                  TextField(
                    controller: _expenseLabelController,
                    decoration: InputDecoration(
                      labelText: 'تسمية العمليات الصادرة',
                      hintText: 'مثال: مصروف، خرج، دفع',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.arrow_upward, color: Colors.red),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () {
                          themeProvider.setExpenseLabel(_expenseLabelController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم حفظ تسمية العمليات الصادرة'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // زر إعادة تعيين التسميات
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('إعادة تعيين التسميات'),
                            content: const Text('هل تريد إعادة تعيين تسميات العمليات للقيم الافتراضية؟'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('إلغاء'),
                              ),
                              TextButton(
                                onPressed: () {
                                  themeProvider.resetLabelsToDefault();
                                  _incomeLabelController.text = themeProvider.incomeLabel;
                                  _expenseLabelController.text = themeProvider.expenseLabel;
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم إعادة تعيين التسميات بنجاح'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                child: const Text('موافق'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh, color: Colors.orange),
                      label: const Text('إعادة تعيين التسميات'),
                    ),
                  ),
                ],
              ),
            ),
          ),

        
          const SizedBox(height: 16),

          // Reset Settings
          Card(
            child: ListTile(
              leading: const Icon(Icons.restart_alt, color: Colors.red),
              title: const Text('إعادة تعيين جميع الإعدادات', style: TextStyle(color: Colors.red)),
              subtitle: const Text('استعادة جميع الإعدادات للقيم الافتراضية'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('إعادة تعيين جميع الإعدادات'),
                    content: const Text('هل تريد استعادة جميع الإعدادات للقيم الافتراضية؟ هذا يشمل المظهر والألوان وتسميات العمليات.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // إعادة تعيين جميع الإعدادات مع تحديث العمليات
                          await themeProvider.resetAllSettings();
                          
                          // تحديث حقول النص
                          _incomeLabelController.text = themeProvider.incomeLabel;
                          _expenseLabelController.text = themeProvider.expenseLabel;
                          
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إعادة تعيين جميع الإعدادات وتحديث العمليات بنجاح'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: const Text('موافق', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}