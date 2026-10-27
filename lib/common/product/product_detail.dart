import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database_handler.dart';
import '../../models/food_item.dart';
import '../../providers/auth_providers.dart';

class ProductDetailScreen extends StatefulWidget {
  final FoodItem foodItem;

  const ProductDetailScreen({super.key, required this.foodItem});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<ExtraItem> selectedExtras = [];
  int totalPrice = 0;

  void _updateTotal() {
    totalPrice = widget.foodItem.price;
    for (var extra in selectedExtras) {
      totalPrice += extra.price;
    }
  }

  @override
  void initState() {
    super.initState();
    _updateTotal();
  }

  void _toggleExtra(ExtraItem extra) {
    setState(() {
      if (selectedExtras.contains(extra)) {
        selectedExtras.remove(extra);
      } else {
        selectedExtras.add(extra);
      }
      _updateTotal();
    });
  }

  void _addToCart() {
    String extras = selectedExtras.map((e) => e.title).join(", ");
    final authProvider = context.read<AuthProvider>();
    final userEmail = authProvider.currentEmail;

    DatabaseService().addToCart(
      widget.foodItem.imagePath,
      widget.foodItem.name,
      totalPrice,
      extras,
      userEmail!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.foodItem.name} Added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.foodItem.name,
            style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 30, bottom: 36),
                width: 300,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(widget.foodItem.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const Text(
              'Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.foodItem.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add Extra ingredients',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.foodItem.extraItems.length,
                itemBuilder: (context, index) {
                  ExtraItem extra = widget.foodItem.extraItems[index];
                  return CheckboxListTile(
                    title: Text(extra.title),
                    subtitle: Text('Rp. ${extra.price}'),
                    value: selectedExtras.contains(extra),
                    onChanged: (bool? value) {
                      _toggleExtra(extra);
                    },
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  _addToCart();
                  FirebaseAnalytics.instance.logEvent(name: "added to cart");

                  Navigator.pop(context);
                },
                child: Text(
                  'Tambahkan ke Keranjang - Rp. $totalPrice',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
