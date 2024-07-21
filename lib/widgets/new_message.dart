import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }

  _messageSend() async {
    final enteredmessage = _messageController.text;
    if (enteredmessage.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();

    final User user = FirebaseAuth.instance.currentUser!;
    final userdata = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    await FirebaseFirestore.instance.collection('chat').add({
      'text': enteredmessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userdata.data()!['username'],
      'userImage': userdata.data()!['image_url'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 1,
        bottom: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: "send a message.."),
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              enableSuggestions: true,
            ),
          ),
          IconButton(
              onPressed: _messageSend,
              icon: Icon(Icons.send,
                  color: Theme.of(context).colorScheme.primary))
        ],
      ),
    );
  }
}
