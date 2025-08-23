import 'package:flutter/material.dart';
import '../data.dart';
//import 'account_detail_page.dart';
import 'transactions_page.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الحسابات")),
      body: ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (_, i) {
          final acc = accounts[i];
          return ListTile(
            leading: Hero(
              tag: 'accountHero${acc['id']}',
              child: CircleAvatar(child: Text(acc['name'][0].toUpperCase())),
            ),
            title: Hero(
              tag: 'accountNameHero${acc['id']}',
              child: Material(
                color: Colors.transparent,
                child: Text(acc['name'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactionsPage(account: acc),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
