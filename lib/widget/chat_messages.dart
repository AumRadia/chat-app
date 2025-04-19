import 'package:chat_app/widget/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticateduser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatsnapshot) {
        if (chatsnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (chatsnapshot.hasData && chatsnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages yet'),
          );
        }

        if (chatsnapshot.hasError) {
          return const Center(
            child: Text('An error occurred'),
          );
        }

        final loadedmessages = chatsnapshot.data!.docs;

        return ListView.builder(
            padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
            reverse: true,
            itemCount: loadedmessages.length,
            itemBuilder: (ctx, index) {
              final chatmessage = loadedmessages[index].data();
              final nextchatmessage = index + 1 < loadedmessages.length
                  ? loadedmessages[index + 1].data()
                  : null;

              final currentmessageuserid = chatmessage['userId'];
              final nextmessageuserid =
                  nextchatmessage != null ? nextchatmessage['userId'] : null;
              final nextuserissame = nextmessageuserid == currentmessageuserid;

              if (nextuserissame) {
                return MessageBubble.next(
                    message: chatmessage['text'],
                    isMe: authenticateduser.uid == currentmessageuserid);
              } else {
                return MessageBubble.first(
                    userImage: chatmessage['userImage'],
                    username: chatmessage['username'],
                    message: chatmessage['text'],
                    isMe: authenticateduser.uid == currentmessageuserid);
              }
            });
      },
    );
  }
}
