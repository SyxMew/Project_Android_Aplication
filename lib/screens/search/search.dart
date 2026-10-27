import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_app/screens/search/widget/item_search.dart';
import '../../models/food_item.dart';

class SearchScreen extends StatelessWidget {
  final String query;

  const SearchScreen({Key? key, required this.query}) : super(key: key);

  Future<List<FoodItem>> fetchSearchedItems() async {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results for "$query"'),
      ),
      body: FutureBuilder<List<FoodItem>>(
        future: fetchSearchedItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No results found for "$query".'));
          }

          final items = snapshot.data!;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ItemSearchCard(
                foodItem: item,
              );
            },
          );
        },
      ),
    );
  }
}
