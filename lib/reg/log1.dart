
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_buddy/reg/reg1.dart';
import 'package:travel_buddy/screens/home_screen.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log-In'),
        backgroundColor: Colors.amber,
      ),
      body: Container(
        color: Colors.amber,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: LoginForm(),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Retrieve stored email during app startup if available
    
  }

 

  // Future<void> _login() async {
  //   try {
  //     await supabase.auth.signInWithPassword(
  //         email: _emailController.text.trim(),
  //         password: _passwordController.text.trim());
  //     if (!mounted) return;

  //     Get.offAllNamed('/home'); // Navigate to home screen using GetX
  //   } on AuthException catch (e) {
  //     print(e);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 350,
            height: 350,
            child: Card(
              color: Colors.amber,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                 if (_formKey.currentState?.validate() ?? false) {
                                print(_emailController);
                                try {
                             await FirebaseAuth.instance.signInWithEmailAndPassword(
                                          email: _emailController.text,
                                          password: _passwordController.text);

                                          if(mounted){
                                         Navigator.of(context).pushReplacement(
                                          
                                          MaterialPageRoute(
                                          builder: (context) => const HomeScreen()));
                                          }
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'wrong-password') {
                                    print('The password is wrong.');
                                  }
                                  if (e.code == 'user-not-found') {
                                    print('No such user exists.');
                                  }
                                } catch (e) {
                                  print(e);
                                }
                              }
                              },
                              child: const Text('Login'),
                            ),
                            Container(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const RegistrationForm()),
                                  );
                                },
                                child: const Text("Don't have an account?"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}