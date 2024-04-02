import 'package:firebase_auth/firebase_auth.dart';
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
    // Get the screen size
    final screenSize = MediaQuery.of(context).size;

    // Calculate the gap and icon size based on the screen width
    final gapSize = screenSize.width * 0.02; // 2% of screen width
    final iconSize = screenSize.width * 0.05; // 5% of screen width

    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        backgroundColor: Colors.grey,
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
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.grey,
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
                gap: gapSize, // Adjusted gap size
                activeColor: Colors.amber,
                iconSize: iconSize, // Adjusted icon size
                padding: const EdgeInsets.all(16),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: Colors.grey.shade900,
                backgroundColor:  Colors.grey,
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
                    icon: LineIcons.telegram,
                    text: 'Requests',
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
