import 'package:flutter/material.dart';
import 'package:test1/accounts_page.dart';
import 'package:test1/add_account_page.dart' show AddAccountPage;
// import 'package:test1/assignment6.dart';




// void main() {
//   runApp(const MyApp());
// }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مدونة الحسابات',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AccountsPage(),
    const AddAccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'الحسابات'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'إضافة حساب'),
        ],
      ),
    );
  }
}
