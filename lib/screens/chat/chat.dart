import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../../database_handler.dart';

class ChatScreen extends StatefulWidget {
  final String userEmail;
  final bool isAdmin;

  ChatScreen({required this.userEmail, this.isAdmin = false});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _databaseService.streamMessages(widget.userEmail).listen((messages) {
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

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    final sender = FirebaseAuth.instance.currentUser!.email;

    await _databaseService.sendMessage(
      senderEmail: sender!,
      receiverEmail: widget.userEmail,
      message: message,
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdmin == false
            ? 'Chat with Admin'
            : widget.userEmail.split('@')[0]),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final sender = data['senderEmail'];
                  final receiver = data['receiverEmail'];

                  return (sender == currentUserEmail &&
                          receiver == widget.userEmail) ||
                      (sender == widget.userEmail &&
                          receiver == currentUserEmail);
                }).toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final doc = messages[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isCurrentUser =
                        data['senderEmail'] == currentUserEmail;

                    final senderLabel = isCurrentUser
                        ? "You"
                        : (widget.isAdmin
                            ? widget.userEmail.split('@')[0]
                            : "Admin");

                    return Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? Colors.blue[100]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              senderLabel,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['message'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your message',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(12),
                    elevation: 5,
                  ),
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
