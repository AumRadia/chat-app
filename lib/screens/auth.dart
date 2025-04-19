import 'dart:io';

import 'package:chat_app/widget/user_image_pciker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class Authscreen extends StatefulWidget {
  const Authscreen({super.key});

  @override
  State<Authscreen> createState() => _AuthscreenState();
}

class _AuthscreenState extends State<Authscreen> {
  final _formkey = GlobalKey<FormState>();
  var _islogin = true;
  var _enteredemail = '';
  var _enteredpassword = '';
  File? _selectedimage;
  var _isauthenticating = false;
  var _enteredusername = '';

  void _submit() async {
    final isvalid = _formkey.currentState!.validate();

    if (!isvalid) {
      return;
    }

    if (!isvalid || !_islogin && _selectedimage == null) {
      return;
    }

    _formkey.currentState!.save();
    try {
      setState(() {
        _isauthenticating = true;
      });
      if (_islogin) {
        final usercredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredemail, password: _enteredpassword);
      } else {
        final usercredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredemail, password: _enteredpassword);

        final storageref = FirebaseStorage.instance
            .ref()
            .child('user-images')
            .child('${usercredentials.user!.uid}.jpg');

        await storageref.putFile(_selectedimage!);
        final imageurl = await storageref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(usercredentials.user!.uid)
            .set({
          'username': _enteredusername,
          'email': _enteredemail,
          'image_url': imageurl
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email already in use') {
        //....
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message ?? 'Authentication Failed'),
      ));

      setState(() {
        _isauthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin:
                    EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset('assets/images/chat.jpg'),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_islogin)
                          UserImagePciker(onpickimage: (pickedimage) {
                            _selectedimage = pickedimage;
                          }),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email adrress',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Plz enter a valid adress';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredemail = value!;
                          },
                        ),
                        if (!_islogin)
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Username '),
                            enableSuggestions: false,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length < 4) {
                                return 'please enter a valid username';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredusername = value!;
                            },
                          ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Plz Enter a long password';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredpassword = value!;
                          },
                        ),
                        const SizedBox(height: 12),
                        if (_isauthenticating)
                          const CircularProgressIndicator(),
                        if (!_isauthenticating)
                          ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                              child: Text(_islogin ? 'Login' : 'Signup')),
                        if (!_isauthenticating)
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  _islogin = !_islogin;
                                });
                              },
                              child: Text(_islogin
                                  ? 'Create an account'
                                  : 'Already have an account'))
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
