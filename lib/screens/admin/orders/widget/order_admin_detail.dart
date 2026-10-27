import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import '../../../../database_handler.dart';

class OrderDetailScreen extends StatefulWidget {
  final String name;
  final int price;
  final String extras;
  final String imagePath;
  final int itemId;
  final String userEmail;
  final String status;

  const OrderDetailScreen({
    required this.name,
    required this.price,
    required this.extras,
    required this.imagePath,
    required this.itemId,
    required this.userEmail,
    required this.status,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final name = widget.userEmail.split('@')[0];
    final displayExtras = widget.extras.isEmpty ? '-' : widget.extras;

    String formatExtras(String extras) {
      if (extras == '-') return '-';

      final items = extras.split(',');
      final formattedExtras = items
          .asMap()
          .entries
          .map((entry) => entry.key == 0
              ? '- ${entry.value.trim()}'
              : '                        - ${entry.value.trim()}')
          .join('\n');
      return formattedExtras;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Atas nama: $name',
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.white, // Text color
                        ),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        text: 'Status: ',
                        style:
                            const TextStyle(fontSize: 17, color: Colors.black),
                        children: [
                          TextSpan(
                            text: widget.status,
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.status == 'Dalam Proses'
                                  ? Colors.blueGrey
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 30, bottom: 36),
                    width: 360,
                    height: 210,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(widget.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Text(
                  'Pesanan: ${widget.name}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Total Price: Rp. ${widget.price}'),
                const SizedBox(height: 8),
                Text('Email: ${widget.userEmail}'),
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                Text(
                  'Extra Items: ${formatExtras(displayExtras)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            widget.status == 'Dalam Proses'
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black),
                        onPressed: () async {
                          await DatabaseService().updateOrderStatus(
                              widget.itemId as String, 'Selesai');

                          FirebaseAnalytics.instance
                              .logEvent(name: "order_status_done");

                          Navigator.pop(context, true);
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Text(
                            'Selesai',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
