import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:food_app/common/bottom_nav/admin_bottom_navbar.dart';
import 'package:food_app/database_handler.dart';
import 'widget/order_admin_detail.dart';

class OrderAdminScreen extends StatefulWidget {
  const OrderAdminScreen({super.key});

  @override
  State<OrderAdminScreen> createState() => _OrderAdminScreenState();
}

class _OrderAdminScreenState extends State<OrderAdminScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = DatabaseService().getAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Daftar Pesanan'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found'));
          } else {
            final orders = snapshot.data!;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                // Validasi dan pastikan tipe data
                final String name = order['name'] ?? 'Unknown';
                final int price =
                    int.tryParse(order['price']?.toString() ?? '0') ?? 0;
                final String userEmail = order['userEmail'] ?? 'Unknown';
                final String status = order['status'] ?? 'Unknown';
                final String imagePath = order['imagePath'] ?? '';
                final String id =
                    order['id'] ?? 'Unknown'; // Tidak dikonversi ke int

                return Column(
                  children: [
                    ListTile(
                      title: Text(name),
                      subtitle: Text(
                        'Price: Rp. $price \nEmail: $userEmail${status == 'Dalam Proses' ? '\nStatus: $status' : ''}',
                      ),
                      leading: SizedBox(
                        width: 60,
                        height: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      trailing: status == 'Dalam Proses'
                          ? ElevatedButton(
                              onPressed: () async {
                                await DatabaseService()
                                    .updateOrderStatus(id, 'Selesai');

                                // Log the order status update event
                                FirebaseAnalytics.instance
                                    .logEvent(name: "order_status_done");

                                setState(() {
                                  _ordersFuture =
                                      DatabaseService().getAllOrders();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Selesai',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const Text(
                              'Selesai',
                              style: TextStyle(color: Colors.green),
                            ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(
                              name: name,
                              price: price,
                              extras: order['extras'],
                              imagePath: imagePath,
                              itemId: int.tryParse(id) ?? 0, // Convert to int
                              userEmail: userEmail,
                              status: status,
                            ),
                          ),
                        );
                        if (result == true) {
                          setState(() {
                            _ordersFuture = DatabaseService().getAllOrders();
                          });
                        }
                      },
                    ),
                    const Divider(
                      indent: 20,
                      endIndent: 20,
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: const BottomAdminNavbar(index: 1),
    );
  }
}
