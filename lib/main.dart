import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_buddy/app_info.dart';
import 'package:travel_buddy/reg/login.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://iaszvhcisppniciyrmsm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlhc3p2aGNpc3BwbmljaXlybXNtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDcxMTI2NjcsImV4cCI6MjAyMjY4ODY2N30.v70IdRrf16oMBhNNtJnzkDQkAWb0RxTShGrhnslus2M',
  );

  // await Permission.locationWhenInUse.isDenied.then(
  //   (valueOfPermisson) {
  //     if (valueOfPermisson) {
  //       Permission.locationWhenInUse.request();
  //     }
  //   },
  // );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
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
          duration: 4000,
          splashTransition: SplashTransition.fadeTransition,
          backgroundColor: Colors.amber,
          nextScreen: LoginPage(),
        ),
      ),
    );
  }
}
