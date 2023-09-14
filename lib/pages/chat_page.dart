import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/components/chat_bubble.dart';
import 'package:demo_app/services/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  const ChatPage(
      {super.key,
      required this.receiverUserEmail,
      required this.receiverUserID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserEmail,
            style: const TextStyle(fontSize: 15, color: Colors.white)),
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.receiverUserID)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return const Text('Loading...');
                  }
                  var isOnline = snapshot.data?['isOnline'];
                  var onlineText = isOnline ? 'Online' : 'Offline';
                  return Text(
                    onlineText,
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(children: [
        Expanded(child: _buildMessageList()),
        _buildMessageInput(),
        const SizedBox(height: 25)
      ]),
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment:
                  (data['senderId'] == _firebaseAuth.currentUser!.uid)
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              mainAxisAlignment:
                  (data['senderId'] == _firebaseAuth.currentUser!.uid)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
              children: [
                Text(data['senderEmail']),
                const SizedBox(height: 5),
                ChatBubble(message: data['message'])
              ]),
        ));
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatService.getMessages(
            widget.receiverUserID, _firebaseAuth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('loading..');
          }

          return ListView(
            children: snapshot.data!.docs
                .map((document) => _buildMessageItem(document))
                .toList(),
          );
        });
  }

  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _messageController,
            decoration: const InputDecoration(
              hintText: 'enter message',
            ),
          ),
        ),
        IconButton(
          onPressed: sendMessage,
          icon: const Icon(
            Icons.arrow_upward,
            size: 40,
          ),
        )
      ],
    );
  }
}
