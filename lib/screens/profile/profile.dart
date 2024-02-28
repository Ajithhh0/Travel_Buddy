import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_buddy/screens/profile/buddy_list.dart';
import 'package:travel_buddy/screens/profile/search.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  String? _avatarUrl;
  String? _username;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  setState(() {
    _avatarUrl = userDoc['avatar_url'];
    _username = userDoc['username'];
  });
}


  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Upload image to Firebase Storage
      String userId = FirebaseAuth.instance.currentUser!.uid;
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref('user/profile/$userId/avatar.jpg');

      await ref.putFile(File(pickedFile.path));

      // Get the download URL
      String downloadURL = await ref.getDownloadURL();

      // Update user profile with the image URL
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'avatar_url': downloadURL});

      setState(() {
        _avatarUrl = downloadURL;
      });
    } else {
      print('No image selected.');
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 200), // Space for the card
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchPage()),
                      );
                    },
                    child: Ink(
                      color: Colors.white,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                        child: Row(
                          children: [
                           SizedBox(width: 1),
                            Text(
                              'Search a Buddy ?',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 1),
                  //buddy_list
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BuddyList()),
                      );
                    },
                    child: Ink(
                      color: Colors.white,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                        child: Row(
                          children: [
                           SizedBox(width: 1),
                            Text(
                              'Buddy List',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10.0,
            left: 5.0,
            right: 5.0,
            child: Card(
              elevation: 10,
              color: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: getImage,
                    child: Padding(
                      padding: const EdgeInsets.all(35.0),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        child: _image != null
                            ? ClipOval(
                                child: Image.file(
                                  _image!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _avatarUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      _avatarUrl!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.camera_alt_outlined,
                                    size: 40,
                                    color: Colors.grey[600],
                                  ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      _username ?? 'Loading...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
