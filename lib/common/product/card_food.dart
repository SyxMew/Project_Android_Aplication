import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../database_handler.dart';
import '../../models/food_item.dart';
import '../../providers/auth_providers.dart';

class FoodItemCard extends StatefulWidget {
  final FoodItem foodItem;

  const FoodItemCard({super.key, required this.foodItem});

  @override
  State<FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<FoodItemCard> {
  void _addToCart() async {
    String extras = '-';
    final authProvider = context.read<AuthProvider>();
    final userEmail = authProvider.currentEmail;

    DatabaseService().addToCart(
      widget.foodItem.imagePath,
      widget.foodItem.name,
      widget.foodItem.price,
      extras,
      userEmail!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.foodItem.name} added to cart!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(widget.foodItem.imagePath),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.foodItem.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  'Rp. ${widget.foodItem.price}',
                  style: const TextStyle(color: Colors.orange),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) {
                          return Icon(
                            index < widget.foodItem.rating
                                ? Icons.star
                                : Icons.star_border,
                            size: 16,
                            color: Colors.orange,
                          );
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.cartPlus,
                          size: 18,
                        ),
                        onPressed: () {
                          // Log event add to cart
                          FirebaseAnalytics.instance
                              .logEvent(name: "add_to_cart");

                          _addToCart();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
