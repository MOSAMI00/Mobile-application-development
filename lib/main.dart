import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/services/theme_provider.dart';
import 'package:test1/views/CategoriesPage.dart';
import 'package:test1/views/accounts/accounts_page.dart';
import 'package:test1/views/accounts/add_account_page.dart';
import 'package:test1/views/settings_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'مدونة الحسابات',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeProvider.primaryColor,
              primary: themeProvider.primaryColor,
            ),
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeProvider.primaryColor,
              primary: themeProvider.primaryColor,
              brightness: Brightness.dark,
            ),
            brightness: Brightness.dark,
          ),
          themeMode: themeProvider.themeMode,
          home: const HomePage(),
        );
      },
    );
  }
}

// باقي الكود...
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Only keep the AccountsPage in the pages list
  final List<Widget> _pages = [
    const AccountsPage(),
    Container(), // Placeholder for the second tab
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _onDrawerItemSelected(String item) {
    Navigator.of(_scaffoldKey.currentContext!).pop();

    switch (item) {
      case 'التصنيفات':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CategoriesPage()),
        );
        break;
      case 'الإعدادات':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsPage()),
        );
        break;
      case 'التقارير':
      case 'كشف الحساب':
      case 'النسخ الاحتياطي':
      case 'المساعدة':
      case 'عن التطبيق':
        _showComingSoonDialog(item);
        break;
      default:
        _showComingSoonDialog(item);
    }
  }

  void _showComingSoonDialog(String title) {
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: const Text('هذه الصفحة سيتم تطويرها لاحقاً.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('مدونة الحسابات'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
      ),
      drawer: _buildDrawer(context),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) {
          if (i == 1) {
            // Navigate to AddAccountPage with push and refresh callback
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddAccountPage()),
            ).then((_) {
              // This will refresh the accounts page when you return
              if (mounted) setState(() {});
            });
          } else {
            setState(() => _selectedIndex = i);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'الحسابات',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'إضافة حساب'),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text(
              'اسم المستخدم',
              style: TextStyle(color: Colors.white),
            ),
            accountEmail: const Text(
              'user@example.com',
              style: TextStyle(color: Colors.white),
            ),
            currentAccountPicture: const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.account_balance_wallet,
                color: Colors.blue,
                size: 35,
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.category,
                  title: 'التصنيفات',
                  onTap: () => _onDrawerItemSelected('التصنيفات'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.bar_chart,
                  title: 'التقارير',
                  onTap: () => _onDrawerItemSelected('التقارير'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.account_balance,
                  title: 'كشف الحساب',
                  onTap: () => _onDrawerItemSelected('كشف الحساب'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.backup,
                  title: 'النسخ الاحتياطي',
                  onTap: () => _onDrawerItemSelected('النسخ الاحتياطي'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'الإعدادات',
                  onTap: () => _onDrawerItemSelected('الإعدادات'),
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.help,
                  title: 'المساعدة',
                  onTap: () => _onDrawerItemSelected('المساعدة'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info,
                  title: 'عن التطبيق',
                  onTap: () => _onDrawerItemSelected('عن التطبيق'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
