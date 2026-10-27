import 'package:flutter/material.dart';
import 'package:food_app/screens/order/order_screen.dart';
import '../../database_handler.dart';

class CartScreen extends StatefulWidget {
  final String userEmail;

  CartScreen({required this.userEmail});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<ValueNotifier<bool>> selectedItems = [];
  bool isEditing = false;

  Future<List<Map<String, dynamic>>> _loadCartItems() async {
    return await DatabaseService().getCart(widget.userEmail);
  }

  void _toggleEditMode(List<Map<String, dynamic>> cartItems) {
    setState(() {
      isEditing = !isEditing;
      if (isEditing) {
        // Set selectedItems to false when entering edit mode
        selectedItems =
            List.generate(cartItems.length, (index) => ValueNotifier(false));
      } else {
        // Reset selectedItems when exiting edit mode
        for (var notifier in selectedItems) {
          notifier.value = false;
        }
      }
    });
  }

  void _deleteSelectedItems(List<Map<String, dynamic>> cartItems) async {
    for (int i = 0; i < selectedItems.length; i++) {
      if (selectedItems[i].value) {
        // Ensure that you're accessing the correct ID field for deletion
        await DatabaseService().removeFromCart(cartItems[i]['id']);
      }
    }

    setState(() {
      // Reset selection and exit edit mode
      for (var notifier in selectedItems) {
        notifier.value = false;
      }
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selected items deleted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Order'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              final cartItems = await _loadCartItems();
              _toggleEditMode(cartItems); // Reset checkbox state on toggle
            },
            child: Text(
              isEditing ? 'Batalkan' : 'Atur',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items in cart'));
          } else {
            final cartItems = snapshot.data!;
            if (selectedItems.length != cartItems.length) {
              // Inisialisasi ulang ValueNotifier jika panjang cartItems berubah
              selectedItems = List.generate(
                  cartItems.length, (index) => ValueNotifier(false));
            }
            return ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      trailing: isEditing
                          ? ValueListenableBuilder<bool>(
                              valueListenable: selectedItems[index],
                              builder: (context, isSelected, child) {
                                return Checkbox(
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    selectedItems[index].value = value ?? false;
                                  },
                                );
                              },
                            )
                          : null,
                      title: Text(cartItems[index]['name']),
                      leading: SizedBox(
                        width: 80,
                        height: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            cartItems[index]['imagePath'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      subtitle: Text('Price: Rp. ${cartItems[index]['price']}'),
                      onTap: () {
                        if (!isEditing) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderScreen(
                                name: cartItems[index]['name'],
                                price: cartItems[index]['price'],
                                extras: cartItems[index]['extras'],
                                imagePath: cartItems[index]['imagePath'],
                                itemId: int.tryParse(
                                        cartItems[index]['id'].toString()) ??
                                    0,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(indent: 20, endIndent: 20),
                  ],
                );
              },
            );
          }
        },
      ),
      floatingActionButton: isEditing
          ? FloatingActionButton(
              onPressed: () async {
                final cartItems = await _loadCartItems();
                _deleteSelectedItems(cartItems);
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.delete),
            )
          : null,
    );
  }
}
