import 'package:flutter/material.dart';
import 'package:food_app/models/food_item.dart';
import '../../../common/product/card_food.dart';
import '../../../common/product/product_detail.dart';

class MenuSearchDelegate extends SearchDelegate {
  final List<FoodItem> menuItems;

  MenuSearchDelegate({required this.menuItems});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredItems = menuItems
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildResultsList(filteredItems, context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

  Widget _buildResultsList(List<FoodItem> items, BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  builder: (context) => ProductDetailScreen(foodItem: item),
                ),
              );
            },
            child: FoodItemCard(foodItem: item),
          );
        },
      ),
    );
  }
}
