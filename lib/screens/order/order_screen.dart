import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../database_handler.dart';

class OrderScreen extends StatefulWidget {
  final String name;
  final int price;
  final String extras;
  final String imagePath;
  final int itemId;
  late final String userEmail;

  OrderScreen({
    required this.name,
    required this.price,
    required this.extras,
    required this.imagePath,
    required this.itemId,
  }) {
    userEmail = FirebaseAuth.instance.currentUser!.email!;
  }

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Future<void> _placeOrder(BuildContext context) async {
    try {
      await DatabaseService().addToOrder(widget.imagePath, widget.name,
          widget.price, widget.extras, widget.userEmail);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 310,
                    height: 280,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.imagePath, // Changed to NetworkImage
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text('Price: Rp. ${widget.price}',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 16.0),
                  Text(
                    'Extra Items: ${formatExtras(displayExtras)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () async {
                    await _placeOrder(context);
                    // Log the order placed event
                    FirebaseAnalytics.instance.logEvent(name: "place_order");

                    final databaseService = DatabaseService();
                    await databaseService
                        .removeFromCart(widget.itemId.toString());

                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      'Pesan',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
