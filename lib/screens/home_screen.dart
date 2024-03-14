import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

import 'package:travel_buddy/reg/log1.dart';
import 'package:travel_buddy/screens/chat/chats.dart';
import 'package:travel_buddy/screens/home.dart';
import 'package:travel_buddy/screens/my%20trips/trips.dart';
import 'package:travel_buddy/screens/profile/profile.dart';
import 'package:travel_buddy/screens/upcoming trips/upcoming.dart';

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
    'Upcoming',
    'Chat',
    'Profile',
  ];
  static final List<Widget> _widgetOptions = <Widget>[
    Home(),
    Trips(),
    UpcomingScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        backgroundColor: const Color.fromARGB(255, 151, 196, 232),
        shadowColor: Colors.yellow,
        automaticallyImplyLeading: false,
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child:Container(
  decoration: const BoxDecoration(
    color: Color.fromARGB(255, 151, 196, 232),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(26.0),
      topRight: Radius.circular(26.0),
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: GNav(
      rippleColor: Colors.grey[600]!,
      hoverColor: Colors.grey[100]!,
      gap: 8,
      activeColor: Colors.amber,
      iconSize: 24,
      padding: const EdgeInsets.all(16),
      duration: const Duration(milliseconds: 400),
      tabBackgroundColor: Colors.grey.shade900,
      backgroundColor: const Color.fromARGB(255, 151, 196, 232),
      color: Colors.black,
      tabs: const [
        GButton(
          icon: LineIcons.home,
          text: 'Home',
        ),
        GButton(
          icon: LineIcons.car,
          text: 'Trips',
        ),
        GButton(
          icon: LineIcons.image,
          text: 'Photos',
        ),
        GButton(
          icon: LineIcons.rocketChat,
          text: 'Chat',
        ),
        GButton(
          icon: LineIcons.user,
          text: 'Profile',
        ),
      ],
      selectedIndex: _selectedIndex,
      onTabChange: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    ),
  ),
),

        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}
