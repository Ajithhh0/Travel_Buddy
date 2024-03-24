import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_buddy/screens/profile/buddy_list.dart';
import 'package:travel_buddy/screens/profile/editprofile.dart';
import 'package:travel_buddy/screens/profile/search.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  String? _avatarUrl;
  String? _username;
  String? _email;
  String? _mobile;
  String? _dob;
  String? _fullName;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    setState(() {
      _avatarUrl = userDoc['avatar_url'];
      _username = userDoc['username'];
      _email = userDoc['email'];
      _mobile = userDoc['mobile'];
      _dob = userDoc['dob'];
      _fullName = userDoc['full_name'];
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
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 200), // Space for the card
                    // Display username
                    Center(
                      child: Text(
                        '$_username' ?? 'Loading...',
                        style: GoogleFonts.poppins(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const EditProfile()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors
                                .white,
                                backgroundColor: Colors
                                .orange, // Use a solid color for the button's text and icon
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  25.0), // Adjust the radius as needed
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                          ),
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    // Display user details in a table
                    Table(
                      defaultColumnWidth: const FlexColumnWidth(1.0),
                      children: [
                        _buildTableRow('Full Name:', _fullName ?? 'Loading...'),
                        _buildTableRow('Email:', _email ?? 'Loading...'),
                        _buildTableRow('Mobile:', _mobile ?? 'Loading...'),
                        _buildTableRow('Date of Birth:', _dob ?? 'Loading...'),
                      ],
                    ),
                    const SizedBox(
                        height: 15), // Space between user details and buttons
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SearchPage()),
                            );
                          },
                          child: const Text('Search a Buddy'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const BuddyList()),
                            );
                          },
                          child: const Text('Buddy List'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 10.0,
            left: 5.0,
            right: 5.0,
            child: GestureDetector(
              onTap: getImage,
              child: Padding(
                padding: const EdgeInsets.all(35.0),
                child: CircleAvatar(
                  radius: 80, // Increased radius
                  backgroundColor: Colors.grey[300],
                  child: _image != null
                      ? ClipOval(
                          child: Image.file(
                            _image!,
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _avatarUrl != null
                          ? ClipOval(
                              child: Image.network(
                                _avatarUrl!,
                                width: 160,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt_outlined,
                              size: 40,
                              color: Colors.grey,
                            ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String title, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
