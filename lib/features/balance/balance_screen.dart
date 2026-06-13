import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';

class BalanceScreen extends StatelessWidget {
  const BalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<TransactionModel>('transactions').listenable(),
        builder: (context, Box<TransactionModel> box, _) {
          if (box.isEmpty) return const Center(child: Text('No transactions yet. Start mining!'));

          final txs = box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.builder(
            itemCount: txs.length,
            itemBuilder: (context, index) {
              final tx = txs[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: tx.type == 'mine' ? Colors.green.shade100 : Colors.blue.shade100,
                  child: Icon(
                    tx.type == 'mine' ? Icons.construction : Icons.send,
                    color: tx.type == 'mine' ? Colors.green : Colors.blue,
                  ),
                ),
                title: Text(tx.type.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat('MMM dd, yyyy - HH:mm').format(tx.timestamp)),
                trailing: Text(
                  '+${tx.amount.toStringAsFixed(6)} GAMMA',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
