import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/message_bubble.dart';

final authUser = FirebaseAuth.instance.currentUser;

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('not message found'),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          final loadedMessage = snapshot.data!.docs;
          return ListView.builder(
              padding:const EdgeInsets.only(left: 13, right: 13, bottom: 40),
              reverse: true,
              itemCount: loadedMessage.length,
              itemBuilder: (ctx, index) {
                final chatMessage = loadedMessage[index].data();
                final nextMessage = loadedMessage.length > index + 1
                    ? loadedMessage[index + 1].data()
                    : null;

                final currentMessageUserId = chatMessage['userId'];

                final nextMessageUserId =
                    nextMessage != null ? nextMessage['userId'] : null;
                final bool nextMessageIsSame =
                    currentMessageUserId == nextMessageUserId;

                if (nextMessageIsSame) {
                  return MessageBubble.next(
                      message: chatMessage['text'],
                      isMe:
                          authUser!.uid == currentMessageUserId ? true : false);
                } else {
                 return MessageBubble.first(
                      userImage: chatMessage['userImage'],
                      username: chatMessage['username'],
                      message: chatMessage['text'],
                      isMe:
                          authUser!.uid == currentMessageUserId ? true : false);
                }
              });
        });
  }
}
