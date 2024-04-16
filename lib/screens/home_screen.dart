import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_buddy/misc_widgets/drawer.dart';
import 'package:travel_buddy/reg/log1.dart';
import 'package:travel_buddy/screens/chat/chats.dart';
import 'package:travel_buddy/screens/home.dart';
import 'package:travel_buddy/screens/my%20trips/trips.dart';
import 'package:travel_buddy/screens/profile/profile.dart';
import 'package:travel_buddy/screens/trip_requests.dart/trip_requests.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    Home(),
    Trips(),
    TripRequestsScreen(),
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
      drawer: MyDrawer(),
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
            icon: Icon(LineIcons.rocketChat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineIcons.user),
            label: 'Profile',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1.0, 0.0),
              end: Offset(0.0, 0.0),
            ).animate(animation),
            child: child,
          );
        },
        child: _widgetOptions[_selectedIndex],
      ),
    );
  }
}
