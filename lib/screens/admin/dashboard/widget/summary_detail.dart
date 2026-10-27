import 'package:flutter/material.dart';
import 'summary_row.dart';

class SummaryDetails extends StatelessWidget {
  final int dailyOrderCount;
  final int monthlyOrderCount;
  final int yearlyOrderCount;
  final int yearlyTotal;

  const SummaryDetails({
    required this.dailyOrderCount,
    required this.monthlyOrderCount,
    required this.yearlyOrderCount,
    required this.yearlyTotal,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SummaryRow(label: 'Total Order (tanggal)', value: dailyOrderCount),
            SummaryRow(label: 'Total Order (bulan)', value: monthlyOrderCount),
            SummaryRow(label: 'Total Order (tahun)', value: yearlyOrderCount),
            SummaryRow(
              label: 'Total Pendapatan (tahun)',
              value: yearlyTotal,
              isCurrency: true,
            ),
          ],
        ),
      ),
    );
  }
}
