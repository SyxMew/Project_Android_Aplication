import 'package:flutter/material.dart';
import 'package:food_app/common/bottom_nav/admin_bottom_navbar.dart';
import 'package:food_app/database_handler.dart'; // Ensure this import is correct for your database handler

class AddFoodItemScreen extends StatefulWidget {
  @override
  _AddFoodItemScreenState createState() => _AddFoodItemScreenState();
}

class _AddFoodItemScreenState extends State<AddFoodItemScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  double _rating = 0.0;
  bool _isPopular = false;
  List<Map<String, dynamic>> _extraItems = [];

  final _formKey = GlobalKey<FormState>();

  // Function to add the food item
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text;
      final price = num.tryParse(_priceController.text) ?? 0;
      final category = _categoryController.text;
      final description = _descriptionController.text;
      final imagePath = _imageUrlController.text;

      await DatabaseService().addFoodItem(
        name: name,
        price: price,
        category: category,
        description: description,
        imagePath: imagePath,
        isPopular: _isPopular,
        rating: _rating,
        extraItems: _extraItems,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Food item "$name" added successfully')),
      );

      // Clear fields after submission
      _nameController.clear();
      _priceController.clear();
      _categoryController.clear();
      _descriptionController.clear();
      _imageUrlController.clear();
      setState(() {
        _rating = 0.0;
        _isPopular = false;
        _extraItems.clear();
      });
    }
  }

  // UI to create extra items dynamically (as an example)
  void _addExtraItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _extraTitleController = TextEditingController();
        final _extraPriceController = TextEditingController();
        return AlertDialog(
          title: const Text("Add Extra Item"),
          content: Column(
            children: [
              TextField(
                controller: _extraTitleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _extraPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final title = _extraTitleController.text;
                final price = int.tryParse(_extraPriceController.text) ?? 0;
                if (title.isNotEmpty && price > 0) {
                  setState(() {
                    _extraItems.add({'title': title, 'price': price});
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food Item'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Rating:'),
                  Slider(
                    value: _rating,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: _rating.toString(),
                    onChanged: (value) {
                      setState(() {
                        _rating = value;
                      });
                    },
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('Is this food item popular?'),
                value: _isPopular,
                onChanged: (value) {
                  setState(() {
                    _isPopular = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addExtraItem,
                child: const Text('Add Extra Item'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Food Item'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomAdminNavbar(index: 3),
    );
  }
}
