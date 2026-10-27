import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_app/screens/admin/add%20menu/add.dart';
import 'package:food_app/screens/admin/chat%20admin/chat_admin.dart';
import 'package:food_app/screens/admin/orders/order_admin.dart';
import 'package:food_app/screens/admin/dashboard/dashbord.dart';

class BottomAdminNavbar extends StatelessWidget {
  final int index;
  const BottomAdminNavbar({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black.withAlpha(100),
      onTap: (int selectedIndex) {
        if (selectedIndex == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminChatScreen(),
            ),
          );
        } else if (selectedIndex == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const OrderAdminScreen(),
            ),
          );
        } else if (selectedIndex == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDashboard(),
            ),
          );
        } else if (selectedIndex == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AddFoodItemScreen(),
            ),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.comments),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.basketShopping),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.tableColumns),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.plus),
          label: 'Add Menu',
        ),
      ],
    );
  }
}
