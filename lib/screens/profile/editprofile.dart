import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _usnController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;

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
      _nameController.text = userDoc['full_name'] ?? '';
      _usnController.text = userDoc['username'] ?? '';
      _emailController.text = userDoc['email'] ?? '';
      _mobileController.text = userDoc['mobile'] ?? '';
      _dobController.text = userDoc['dob'] ?? '';
      _selectedDate =
          userDoc['dob'] != null ? DateTime.parse(userDoc['dob']) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 350,
            height: 700,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      onChanged: (value) {
                        _updateUserData('full_name', value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _usnController,
                      onChanged: (value) {
                        _updateUserData('username', value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _emailController,
                      onChanged: (value) {
                        _updateUserData('email', value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _mobileController,
                      onChanged: (value) {
                        _updateUserData('mobile', value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Mobile',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 110, 103, 103),
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Date of Birth: '),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null && picked != _selectedDate) {
                                setState(() {
                                  _selectedDate = picked;
                                });
                                _updateUserData(
                                    'dob',
                                    _selectedDate != null
                                        ? _selectedDate!
                                            .toLocal()
                                            .toString()
                                            .split(' ')[0]
                                        : '');
                              }
                            },
                            child: Text(
                              _selectedDate != null
                                  ? _selectedDate!
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0]
                                  : 'Select Date',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateUserData(String field, String value) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({field: value});
  }

  void _saveChanges() {
    // Here you can add any additional actions you want to perform before saving changes
    print('Saving changes...');
    Navigator.pop(context);
  }
}
