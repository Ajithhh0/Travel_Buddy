import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_buddy/reg/log1.dart';
import 'package:travel_buddy/screens/chat/chats.dart';
import 'package:travel_buddy/screens/home.dart';
import 'package:travel_buddy/screens/my%20trips/trips.dart';
import 'package:travel_buddy/screens/profile/profile.dart';
import 'package:travel_buddy/screens/trip_requests.dart/trip_requests.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static const List<String> _titles = [
    'Home',
    'Trips',
    'Trip Requests',
    'Chat',
    'Profile',
  ];
  static final List<Widget> _widgetOptions = <Widget>[
    // Replace these with your actual home screen widgets
    Home(),
    Trips(),
    TripRequestsScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  File? _avatarImage;
  String? _avatarUrl;
  String? avatarUrl; // Define avatarUrl here
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _mobileController = TextEditingController();
  String? _genderValue;
  DateTime? _selectedDate; // Added variable to store selected date

  bool _allFieldsCompleted = false;

  @override
  void initState() {
    super.initState();
    checkAndShowDialog();
  }

  Future<void> checkAndShowDialog() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      var data = userData.data() as Map<String, dynamic>;
      //bool hasEmptyFields = data.containsValue('');
      if (data['filled_status'] == 1) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Fill Required Fields'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickAvatarImage,
                      child: CircleAvatar(
                        radius: 80, // Increased radius
                        backgroundColor: Colors.grey[300],
                        child: _avatarImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _avatarImage!,
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _avatarUrl != null
                                ? ClipOval(
                                    child: Image.file(
                                      // Use Image.file for local file path
                                      File(
                                          _avatarUrl!), // Use _avatarUrl as local file path
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
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    controller: _nameController,
                    onChanged: (_) => _checkFieldsCompletion(),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Username'),
                    controller: _usernameController,
                    onChanged: (_) => _checkFieldsCompletion(),
                  ),
                  // ListTile(
                  //   title: Text('Date of Birth'),
                  //   subtitle: Text(_selectedDate),
                  //   onTap: () => _selectDate(context),
                  // ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Date of Birth: ',
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () async {
                          await _selectDate(context);
                        },
                        child: Text(
                          _selectedDate != null
                              ? _selectedDate!.toString().split(' ')[0]
                              : 'Select Date',
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Mobile'),
                    controller: _mobileController,
                    onChanged: (_) => _checkFieldsCompletion(),
                  ),
                  DropdownButtonFormField<String>(
                    value: _genderValue,
                    items: ['Male', 'Female', 'Other', 'Prefer not to say']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _genderValue = value;
                      });
                      _checkFieldsCompletion();
                    },
                    decoration: InputDecoration(labelText: 'Gender'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: _allFieldsCompleted
                    ? () {
                        _saveDetailsToDB(user.uid);
                      }
                    : null,
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _pickAvatarImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
        _avatarUrl = pickedFile.path; // Set _avatarUrl to local file path
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _checkFieldsCompletion(); // Trigger field completion check
      });
    }
  }

  void _checkFieldsCompletion() {
    setState(() {
      _allFieldsCompleted = _nameController.text.isNotEmpty &&
          _usernameController.text.isNotEmpty &&
          _selectedDate != null &&
          _mobileController.text.isNotEmpty &&
          _genderValue != null;
    });
  }

  Future<void> _saveDetailsToDB(String userId) async {
    avatarUrl = ''; // Set avatarUrl here

    if (_avatarImage != null) {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref('user/profile/$userId/avatar.jpg');
      await ref.putFile(_avatarImage!);
      avatarUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'avatar_url': avatarUrl,
      'full_name': _nameController.text,
      'username': _usernameController.text,
      'dob': _selectedDate, // Use selected date
      'mobile': _mobileController.text,
      'gender': _genderValue,
      'filled_status': 0,
    }, SetOptions(merge: true));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.grey[700],
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LineIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineIcons.car),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineIcons.telegram),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineIcons.user),
            label: 'Profile',
          ),
        ],
      ),
      body: _widgetOptions[_selectedIndex],
    );
  }
}
