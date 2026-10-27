class FoodItem {
  final String name;
  final int price;
  final String imagePath;
  final String description;
  final String category;
  final int rating;
  final List<ExtraItem> extraItems;

  FoodItem({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
    required this.category,
    required this.rating,
    required this.extraItems,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      price: (json['price'] is int)
          ? json['price']
          : (json['price'] as num).toInt(),
      imagePath: json['imagePath'] ?? '',
      description: json['description'] ?? '',
      category: json['category'],
      rating: (json['rating'] is int)
          ? json['rating']
          : (json['rating'] as num).toInt(),
      extraItems: (json['extraItems'] as List<dynamic>).map((extra) {
        return ExtraItem.fromJson(extra);
      }).toList(),
    );
  }
}

class ExtraItem {
  final String title;
  final int price;

  ExtraItem({
    required this.title,
    required this.price,
  });

  factory ExtraItem.fromJson(Map<String, dynamic> json) {
    return ExtraItem(
      title: json['title'],
      price: (json['price'] is int)
          ? json['price']
          : (json['price'] as num).toInt(),
    );
  }
}
