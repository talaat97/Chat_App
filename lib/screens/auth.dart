// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/user_image.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

bool _isLogin = true;
var _enterdEmail = '';
var _enteredUsername = '';
var _enterdPassword = '';
File? _selectedImage;
var isUpLoading = false;

final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

class _AuthScreenState extends State<AuthScreen> {
  _submit() async {
    final valid = _formkey.currentState!.validate();

    if (!valid || (!_isLogin && _selectedImage == null)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pike Image Pleas')));
      return;
    }
    try {
      setState(() {
        isUpLoading = true;
      });

      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
          email: _enterdEmail,
          password: _enterdPassword,
        );
      } else {
        final UserCredential userCredential =
            await _firebase.createUserWithEmailAndPassword(
          email: _enterdEmail,
          password: _enterdPassword,
        );

        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('user_Image')
            .child('${userCredential.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);
        final imageUrlInCloud = await storageRef.getDownloadURL();
        log(imageUrlInCloud);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enterdEmail,
          'image_url': imageUrlInCloud,
        });
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication failed')));

      setState(() {
        isUpLoading = false;
      });
    }

    _formkey.currentState!.save();
    log(_enterdEmail);
    log(_enterdPassword);
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
                width: 200,
                margin: const EdgeInsets.only(
                  top: 30,
                  right: 20,
                  left: 20,
                  bottom: 20,
                ),
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          if (!_isLogin)
                            UserImagePiker(
                              onpikedImage: (pikedImage) {
                                _selectedImage = pikedImage;
                              },
                            ),
                          TextFormField(
                            onSaved: (value) => _enterdEmail = value!,
                            decoration:
                                const InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              onSaved: (value) => _enteredUsername = value!,
                              decoration:
                                  const InputDecoration(labelText: 'User Name'),
                              validator: (value) {
                                if (value == null || value.trim().length < 4) {
                                  return 'please inter at least 4 charaters ';
                                }
                                return null;
                              },
                            ),
                          const SizedBox(height: 3),
                          TextFormField(
                            onSaved: (value) => _enterdPassword = value!,
                            decoration:
                                const InputDecoration(labelText: 'password'),
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'please enter a valid password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          //  if (_isUpLoading) const CircularProgressIndicator(),
                          //if (!_isUpLoading)
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                onPressed: _submit,
                                child: Text(_isLogin ? 'login' : 'sigup')),
                         // if (!_isUpLoading)
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin
                                    ? 'Create an account'
                                    : 'I already have one')),
                        ],
                      ),
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
