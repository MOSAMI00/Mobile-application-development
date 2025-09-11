import 'package:flutter/material.dart';

class AccountDetailPage extends StatelessWidget {
  final Map<String, dynamic> account;
  const AccountDetailPage({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(account['name'])),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'accountHero${account['id']}',
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blueAccent,
                child: Text(
                  account['name'][0].toUpperCase(),
                  style: const TextStyle(fontSize: 50, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Hero(
              tag: 'accountNameHero${account['id']}',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  account['name'],
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "تفاصيل الحساب ستضاف هنا لاحقاً",
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
