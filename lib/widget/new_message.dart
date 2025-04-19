import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var messagecontroller = TextEditingController();

  @override
  void dispose() {
    messagecontroller.dispose();
    super.dispose();
  }

  void _submitmessage() async {
    final _enteredmessage = messagecontroller.text;

    if (_enteredmessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    messagecontroller.clear();

    final user = FirebaseAuth.instance.currentUser!;
    final userdata = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': _enteredmessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userdata.data()!['username'],
      'userImage': userdata.data()!['image_url'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messagecontroller,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: false,
              enableSuggestions: true,
              decoration: InputDecoration(labelText: 'Send a message...'),
            ),
          ),
          IconButton(
              color: Theme.of(context).colorScheme.primary,
              onPressed: _submitmessage,
              icon: Icon(Icons.send))
        ],
      ),
    );
  }
}
