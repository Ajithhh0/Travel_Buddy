import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:travel_buddy/firebase_options.dart';

import 'package:travel_buddy/misc/app_info.dart';
import 'package:travel_buddy/misc/members_provider.dart';
import 'package:travel_buddy/misc/tripdetailsprovider.dart';
import 'package:travel_buddy/screens/home_screen.dart';
import 'package:travel_buddy/reg/log1.dart';



void main() async {
 WidgetsFlutterBinding.ensureInitialized();

 await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
 );

 FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print('User is signed out');
    } else {
      print('User is signed in: ${user.uid}');
    }
 });

 runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TripDetailsProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => MemberRefsProvider(), // Add the MemberRefsProvider here
        ),
      ],
      child: MyApp(),
    ),
 );
}

class MyApp extends StatelessWidget {
 @override
 Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(), 
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Travel Buddy',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
          primaryColor: Colors.amber,
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
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
}
