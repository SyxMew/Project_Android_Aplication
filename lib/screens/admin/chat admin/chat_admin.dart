import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import '../../../common/bottom_nav/admin_bottom_navbar.dart';
import '../../../providers/auth_providers.dart';
import '../../chat/chat.dart';
import '../../../database_handler.dart';

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  _AdminChatScreenState createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _databaseService.streamMessages('admin@gmail.com').listen((messages) {
      if (messages.isNotEmpty) {
        final latestMessage = messages.first;
        _showNewMessageNotification(latestMessage);
      }
    });
  }

  void _showNewMessageNotification(Map<String, dynamic> message) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: 'New message from ${message['senderEmail']}',
        body: message['message'],
        notificationLayout: NotificationLayout.Default,
        icon: 'resource://drawable/launcher_icon', // Ensure valid small icon
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'REPLY',
          label: 'Reply',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Chat'),
        automaticallyImplyLeading: false,
        centerTitle: true,
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final Map<String, QueryDocumentSnapshot> latestMessages = {};

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final senderEmail = data['senderEmail'];
            final receiverEmail = data['receiverEmail'];

            if (senderEmail == 'admin@gmail.com' &&
                receiverEmail == 'admin@gmail.com') continue;

            final conversationPartnerEmail =
                senderEmail == 'admin@gmail.com' ? receiverEmail : senderEmail;

            if (!latestMessages.containsKey(conversationPartnerEmail)) {
              latestMessages[conversationPartnerEmail] = doc;
            }
          }

          final senderWidgets = latestMessages.values.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final conversationPartnerEmail =
                data['senderEmail'] == 'admin@gmail.com'
                    ? data['receiverEmail']
                    : data['senderEmail'];
            return ListTile(
              title: Text(
                conversationPartnerEmail.split('@')[0],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/logo_profile.png'),
              ),
              subtitle: Text(data['message']),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        userEmail: conversationPartnerEmail,
                        isAdmin: true,
                      ),
                    ));
              },
            );
          }).toList();

          return ListView(children: senderWidgets);
        },
      ),
      bottomNavigationBar: const BottomAdminNavbar(index: 0),
    );
  }
}
