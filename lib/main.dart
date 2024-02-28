import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_buddy/firebase_options.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_buddy/misc/app_info.dart';
import 'package:travel_buddy/screens/home_screen.dart';
//import 'package:travel_buddy/reg/login.dart';
import 'package:travel_buddy/reg/log1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ensure that plugins are initialized
  // await Supabase.initialize(
  //   url: 'https://iaszvhcisppniciyrmsm.supabase.co',
  //   anonKey:
  //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlhc3p2aGNpc3BwbmljaXlybXNtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDcxMTI2NjcsImV4cCI6MjAyMjY4ODY2N30.v70IdRrf16oMBhNNtJnzkDQkAWb0RxTShGrhnslus2M',
  // );

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      
      print('User is signed out');
    } else {
     
      print('User is signed in: ${user.uid}');
      
    }
  });

  runApp(MyApp());
}

//final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(), // Your ChangeNotifier here
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Travel Buddy',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
          primaryColor: Colors.amber,
          useMaterial3: true,
        ),
        home: AnimatedSplashScreen(
          splash: Image.asset('assets/images/jeep.png'),
          splashIconSize: double.infinity,
          duration: 3000,
          splashTransition: SplashTransition.fadeTransition,
          backgroundColor: Colors.amber,
          nextScreen: FirebaseAuth.instance.currentUser == null 
          ? const LoginPage()
          : const HomeScreen(),
        ),
      ),
    );
  }

  // Widget _getNextScreen() {
  //   // Check if user is logged in or not
  //   final isLoggedIn = supabase.auth.currentUser != null;
  //   if (isLoggedIn) {
  //     return const HomeScreen();
  //   } else {
  //     return const LoginPage();
  //   }
  // }
}
