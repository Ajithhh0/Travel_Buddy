import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_buddy/screens/home_screen.dart';
import 'package:travel_buddy/reg/login.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://iaszvhcisppniciyrmsm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlhc3p2aGNpc3BwbmljaXlybXNtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDcxMTI2NjcsImV4cCI6MjAyMjY4ODY2N30.v70IdRrf16oMBhNNtJnzkDQkAWb0RxTShGrhnslus2M',
  );

  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
        nextScreen: _getNextScreen(),
      ),
      getPages: [
        GetPage(name: '/home', page: () => HomeScreen()),
      ],
    );
  }

  Widget _getNextScreen() {
    // Check if user is logged in or not
    final isLoggedIn = supabase.auth.currentUser != null;
    if (isLoggedIn) {
      
      return const HomeScreen();
    } else {
      
      return const LoginPage();
    }
  }
}
