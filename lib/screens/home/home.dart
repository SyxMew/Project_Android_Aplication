import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_app/common/bottom_nav/bottom_navbar.dart';
import 'package:food_app/models/food_item.dart';
import 'package:food_app/screens/cart/cart.dart';
import 'package:food_app/common/product/product_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:food_app/utils/location_utils.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:food_app/utils/Addmob.dart';

import '../../common/product/card_food.dart';
import '../chat/chat.dart';
import '../search/search.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> imagePaths = [
    'https://assets-a1.kompasiana.com/items/album/2023/06/12/nasi-goreng-indonesian-fried-rice-sugar-spice-more-6486e9184d498a53171a2c62.jpeg',
    'https://assets-a1.kompasiana.com/items/album/2023/06/12/nasi-goreng-indonesian-fried-rice-sugar-spice-more-6486e9184d498a53171a2c62.jpeg',
    'https://assets-a1.kompasiana.com/items/album/2023/06/12/nasi-goreng-indonesian-fried-rice-sugar-spice-more-6486e9184d498a53171a2c62.jpeg',
  ];

  int _currentPage = 0;
  List<FoodItem> _foodItems = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _currentAddress = 'Fetching location...';
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
    _determinePosition();
    _loadBannerAd();
    startPromotionNotifications();
    loadInterstitialAd(); // Load the interstitial ad
  }

  Future<void> _fetchFoodItems() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('food_items')
          .where('isPopular', isEqualTo: true)
          .get();

      setState(() {
        _foodItems = snapshot.docs.map((doc) {
          final data = doc.data();
          return FoodItem(
            name: data['name'],
            price: (data['price'] as num).toInt(),
            imagePath: data['imagePath'],
            description: data['description'],
            category: data['category'],
            rating: (data['rating'] as num).toInt(),
            extraItems:
                (data['extraItems'] as List<dynamic>? ?? []).map((extra) {
              return ExtraItem(
                title: extra['title'],
                price: (extra['price'] as num).toInt(),
              );
            }).toList(),
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _determinePosition() async {
    await determinePosition((address) {
      setState(() {
        _currentAddress = address;
      });
    });
  }

  void _searchFood() {
    if (_searchController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchScreen(query: _searchController.text),
        ),
      );
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
    )..load();
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

  Future<void> startPromotionNotifications() async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: 'PROMOOO!!!',
        body: 'Berikut Promo Makanan Hari Ini!',
      ),
      schedule: NotificationInterval(
        interval: const Duration(seconds: 600),
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: true,
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve localized strings from AppLocalizations
    final localizations = AppLocalizations.of(context)!;

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasError
                ? Center(
                    child: Text(
                        localizations.error_loading)) // Localized error message
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: localizations
                                .search_hint, // Localized hint text
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          onSubmitted: (_) => _searchFood(),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          localizations
                              .today_food_deals, // Localized text for the section header
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            CarouselSlider(
                              items: imagePaths.map((imagePath) {
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    image: DecorationImage(
                                      image: NetworkImage(imagePath),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              }).toList(),
                              options: CarouselOptions(
                                initialPage: 0,
                                height: 160,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 2),
                                enlargeCenterPage: true,
                                viewportFraction: 0.9,
                                onPageChanged: (value, _) {
                                  setState(() {
                                    _currentPage = value;
                                  });
                                },
                              ),
                            ),
                            buildCarouselIndicator(),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localizations
                                  .popular_items, // Localized title for popular items section
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/menu');
                              },
                              child: Text(localizations
                                  .view_all), // Localized button text
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2 / 2.7,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 40,
                          ),
                          itemCount: _foodItems.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(
                                      foodItem: _foodItems[index],
                                    ),
                                  ),
                                );
                              },
                              child: FoodItemCard(foodItem: _foodItems[index]),
                            );
                          },
                        ),
                        if (_bannerAd != null)
                          Container(
                            alignment: Alignment.center,
                            width: _bannerAd!.size.width.toDouble(),
                            height: _bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: _bannerAd!),
                          ),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: const BottomNavbar(index: 0),
    );
  }

  Widget buildCarouselIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < imagePaths.length; i++)
          Container(
            margin: const EdgeInsets.all(5),
            height: i == _currentPage ? 7 : 5,
            width: i == _currentPage ? 7 : 5,
            decoration: BoxDecoration(
                color: i == _currentPage ? Colors.black : Colors.grey,
                shape: BoxShape.circle),
          ),
      ],
    );
  }
}
