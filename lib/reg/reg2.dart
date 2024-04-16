  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:travel_buddy/misc_widgets/buttons.dart';
  import 'package:travel_buddy/screens/home_screen2.dart';

  class RegistrationForm extends StatefulWidget {
    const RegistrationForm({Key? key});

    @override
    _RegistrationFormState createState() => _RegistrationFormState();
  }

  class _RegistrationFormState extends State<RegistrationForm> {
    final _formKey = GlobalKey<FormState>();
    
    
    final _emailController = TextEditingController();
    
    final _passwordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Registration',
          ),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Center(

              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: 350,
                  height: 700,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                  height: 120,
                  padding: EdgeInsets.all(1),
                  child: Image.asset(
                    'assets/icons/jeep_icon.png',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 14.0,),
                          Container(
                            width: 300,
                            child: Center(
                              child: TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                         
                          
                          Container(
                            width: 300,
                            child: Center(
                              child: TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Container(
                            width: 300,
                            child: Center(
                              child: TextFormField(
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 40.0),
                          ButtonWidget(text: 'Sign Up', onTap: saveDetails),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    void saveDetails() async {
      if (_formKey.currentState?.validate() ?? false) {
        print(_emailController);
        try {
          UserCredential usercred = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: _emailController.text,
                  password: _passwordController.text);

          if (usercred.user != null) {
            var data = {
              'avatar_url': ' ',
              'full_name': ' ',
              'username': ' ',
              'email': _emailController.text.trim(),
              'mobile': ' ',
              'password': _passwordController.text.trim(),
              'dob':' ',
              'gender': ' ',
              'created_at': DateTime.now(),
              'uid': usercred.user!.uid,
              'filled_status': 1,
            };
            await FirebaseFirestore.instance
                .collection('users')
                .doc(usercred.user!.uid)
                .set(data);
          }

          if (mounted) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomeScreen()));
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            print('The password provided is too weak.');
          } else if (e.code == 'email-already-in-use') {
            print('The account already exists for that email');
          }
        } catch (e) {
          print(e);
        }
      }
    }
  }
