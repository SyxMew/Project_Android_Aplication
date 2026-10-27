import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_app/common/product/card_food.dart';
import 'package:food_app/utils/location_utils.dart';
import '../../common/bottom_nav/bottom_navbar.dart';
import '../chat/chat.dart';
import 'widget/search_delegate.dart';
import '../../models/food_item.dart';
import '../cart/cart.dart';
import '../../common/product/product_detail.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import localization
import 'package:food_app/utils/Addmob.dart'; // Import the ad utility

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<List<FoodItem>> foodItems;
  String selectedCategory = 'Paketan';

  String _currentAddress = 'Fetching location...';

  Future<void> _determinePosition() async {
    await determinePosition((address) {
      setState(() {
        _currentAddress = address;
      });
    });
  }

  Future<List<FoodItem>> _fetchFoodItems() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('food_items').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FoodItem(
          name: data['name'],
          price: (data['price'] as num).toInt(),
          imagePath: data['imagePath'],
          description: data['description'],
          category: data['category'],
          rating: (data['rating'] as num).toInt(),
          extraItems: (data['extraItems'] as List<dynamic>).map((extra) {
            return ExtraItem(
              title: extra['title'],
              price: (extra['price'] as num).toInt(),
            );
          }).toList(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load food items: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    foodItems = _fetchFoodItems();
    _determinePosition();
    loadInterstitialAd(); // Load the interstitial ad
  }

  void _showInterstitialAdAndNavigate() {
    showInterstitialAd(_navigateToCartScreen);
  }

  void _navigateToCartScreen() {
    final User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(userEmail: userEmail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context); // Get localized strings

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(FontAwesomeIcons.locationDot),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                _currentAddress,
                style: const TextStyle(fontSize: 14, color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              foodItems.then((items) {
                showSearch(
                  // ignore: use_build_context_synchronously
                  context: context,
                  delegate: MenuSearchDelegate(menuItems: items),
                );
              });
            },
            icon: const FaIcon(FontAwesomeIcons.magnifyingGlass,
                color: Colors.black),
          ),
          IconButton(
            onPressed: _showInterstitialAdAndNavigate,
            icon: const FaIcon(FontAwesomeIcons.cartShopping,
                color: Colors.black),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatScreen(userEmail: 'admin@gmail.com'),
                ),
              );
            },
            icon: const FaIcon(FontAwesomeIcons.solidCommentDots,
                color: Colors.black),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: FutureBuilder<List<FoodItem>>(
        future: foodItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(localizations?.no_food_items_found ??
                    'No food items found.'));
          }

          final items = snapshot.data!
              .where((item) => item.category == selectedCategory)
              .toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),
                Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = 'Paketan';
                          });
                        },
                        child: Text(
                          localizations?.paketan ??
                              'Paketan', // Localized string
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selectedCategory == 'Paketan'
                                ? Colors.orange
                                : Colors.black,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = 'Makanan';
                          });
                        },
                        child: Text(
                          localizations?.makanan ??
                              'Makanan', // Localized string
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selectedCategory == 'Makanan'
                                ? Colors.orange
                                : Colors.black,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = 'Minuman';
                          });
                        },
                        child: Text(
                          localizations?.minuman ??
                              'Minuman', // Localized string
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selectedCategory == 'Minuman'
                                ? Colors.orange
                                : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2 / 2.7,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 40,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(foodItem: item),
                            ),
                          );
                        },
                        child: FoodItemCard(foodItem: item),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavbar(index: 1),
    );
  }
}
