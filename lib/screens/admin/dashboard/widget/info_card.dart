
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final int amount;

  const InfoCard({required this.title, required this.amount, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Rp.${NumberFormat('#,###').format(amount)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
