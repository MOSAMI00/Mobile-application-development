import 'package:flutter/material.dart';
import 'package:test1/services/preferences_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final PreferencesService _prefs = PreferencesService();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Mode
          Card(
            child: ListTile(
              leading: const Icon(Icons.brightness_4),
              title: const Text('المظهر'),
              subtitle: Text(
                _prefs.themeMode == ThemeMode.dark
                    ? 'مظلم'
                    : _prefs.themeMode == ThemeMode.light
                    ? 'فاتح'
                    : 'تلقائي',
              ),
              trailing: DropdownButton<ThemeMode>(
                value: _prefs.themeMode,
                items: const [
                  DropdownMenuItem(value: ThemeMode.light, child: Text('فاتح')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('مظلم')),
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('تلقائي'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _prefs.themeMode = value!;
                  });
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
                      setState(() {
                        _prefs.primaryColor = color;
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _prefs.primaryColor.value == color.value
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

          // Secondary Color
          // Card(
          //   child: ListTile(
          //     leading: const Icon(Icons.color_lens_outlined),
          //     title: const Text('اللون الثانوي'),
          //     subtitle: Wrap(
          //       spacing: 8,
          //       children: _colorOptions.map((color) {
          //         return GestureDetector(
          //           onTap: () {
          //             setState(() {
          //               _prefs.secondaryColor = color;
          //             });
          //           },
          //           child: Container(
          //             width: 24,
          //             height: 24,
          //             decoration: BoxDecoration(
          //               color: color,
          //               shape: BoxShape.circle,
          //               border: Border.all(
          //                 color: _prefs.secondaryColor.value == color.value
          //                     ? Colors.black
          //                     : Colors.transparent,
          //                 width: 2,
          //               ),
          //             ),
          //           ),
          //         );
          //       }).toList(),
          //     ),
          //   ),
          // ),

          // Notifications
          Card(
            child: SwitchListTile(
              title: const Text('التنبيهات'),
              subtitle: const Text('استلام إشعارات بالعمليات'),
              value: _prefs.notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _prefs.notificationsEnabled = value;
                });
              },
            ),
          ),

          // Reset Settings
          Card(
            child: ListTile(
              leading: const Icon(Icons.restart_alt, color: Colors.red),
              title: const Text(
                'إعادة التعيين',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('إعادة التعيين'),
                    content: const Text(
                      'هل تريد استعادة الإعدادات الافتراضية؟',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _prefs.clearPreferences();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'موافق',
                          style: TextStyle(color: Colors.red),
                        ),
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
