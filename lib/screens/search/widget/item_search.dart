import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../common/product/product_detail.dart';
import '../../../database_handler.dart';
import '../../../models/food_item.dart';
import '../../../providers/auth_providers.dart';

class ItemSearchCard extends StatefulWidget {
  final FoodItem foodItem;

  ItemSearchCard({required this.foodItem});

  @override
  State<ItemSearchCard> createState() => ItemSearchCardState();
}

class ItemSearchCardState extends State<ItemSearchCard> {
  void _addToCart() {
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              foodItem: widget.foodItem,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(15),
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                      widget.foodItem.imagePath), // Changed to NetworkImage
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.foodItem.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Rp. ${widget.foodItem.price}',
                    style: const TextStyle(color: Colors.orange),
                  ),
                  Row(
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
                      const SizedBox(
                        width: 100,
                      ),
                      IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.cartPlus,
                          size: 18,
                        ),
                        onPressed: () {
                          _addToCart();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
