import 'package:flutter/material.dart';
import '../data.dart';
import 'add_transaction_page.dart';

class TransactionsPage extends StatefulWidget {
  final Map<String, dynamic> account;
  const TransactionsPage({super.key, required this.account});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {

  List<Map<String, dynamic>> get accountTxs =>
      transactions.where((tx) => tx['accountId'] == widget.account['id']).toList();

  double get balance {
    double sum = 0;
    for (var tx in accountTxs) {
      sum += (tx['type'] == 'وارد') ? tx['amount'] : -tx['amount'];
    }
    return sum;
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.account['name'])),
      body: Column(
        children: [
          Hero(
            tag: 'accountHero${widget.account['id']}',
            child: CircleAvatar(
              radius: 50,
              child: Text(widget.account['name'][0].toUpperCase(),
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text("الرصيد الحالي: $balance",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: accountTxs.length,
              itemBuilder: (_, i) {
                final tx = accountTxs[i];
                return ListTile(
                  leading: Icon(tx['type'] == 'وارد' ? Icons.arrow_downward : Icons.arrow_upward,
                    color: tx['type'] == 'وارد' ? Colors.green : Colors.red,
                  ),
                  title: Text("${tx['type']} - ${tx['amount']}"),
                  subtitle: Text(tx['category']),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionPage(accountId: widget.account['id']),
            ),
          );
          _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
