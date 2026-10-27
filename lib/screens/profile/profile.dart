import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:food_app/providers/auth_providers.dart';
import '../../common/bottom_nav/bottom_navbar.dart';
import '../../database_handler.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final email = authProvider.currentEmail;
    final name = authProvider.currentUserName;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Konfirmasi Logout'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          'Batal',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'Ya',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ],
                  );
                },
              );
              if (shouldLogout == true) {
                authProvider.logout(context);
              }
            },
            icon: const Icon(FontAwesomeIcons.arrowRightFromBracket),
            iconSize: 18,
          ),
        ],
      ),
      body: email != null
          ? StreamBuilder<List<Map<String, dynamic>>>(
              stream: DatabaseService().streamOrders(email),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final item = snapshot.data;

                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                              'https://example.com/logo_profile.png'), // Changed to NetworkImage
                        ),
                        title: Text(
                          '$name',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Email: $email'),
                      ),
                      const SizedBox(height: 20),
                      ExpansionTile(
                        title: const Text('Daftar pesanan saya'),
                        children: [
                          if (snapshot.hasData && item!.isNotEmpty) ...[
                            for (var i = 0; i < item.length; i++) ...[
                              ListTile(
                                leading: Image.network(
                                  item[i][
                                      'imagePath'], // Menampilkan gambar dari Firestore
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(item[i]['name']),
                                trailing: Text.rich(
                                  TextSpan(
                                    text: 'Status: ',
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text: item[i]['status'],
                                        style: TextStyle(
                                          color: item[i]['status'] ==
                                                  'Dalam Proses'
                                              ? Colors.blueGrey
                                              : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Harga: Rp.${item[i]['price']}'),
                                    if (item[i]['extras'] != null &&
                                        item[i]['extras'] != '-')
                                      Text('Tambahan: ${item[i]['extras']}'),
                                    Text(
                                      'Tanggal: ${DateTime.parse(item[i]['createdAt'].toDate().toString()).toLocal()}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              if (i < item.length - 1)
                                const Divider(), // Divider antar item
                            ],
                          ] else ...[
                            const ListTile(
                              title: Text('Tidak ada pesanan.'),
                            ),
                          ],
                        ],
                      )
                    ],
                  ),
                );
              },
            )
          : const Center(
              child: Text(
                'No user logged in.',
                style: TextStyle(fontSize: 20),
              ),
            ),
      bottomNavigationBar: const BottomNavbar(index: 2),
    );
  }
}
