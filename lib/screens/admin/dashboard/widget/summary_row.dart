import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryRow extends StatelessWidget {
  final String label;
  final int value;
  final bool isCurrency;

  const SummaryRow({
    required this.label,
    required this.value,
    this.isCurrency = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            isCurrency
                ? 'Rp.${NumberFormat('#,###').format(value)}'
                : value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
