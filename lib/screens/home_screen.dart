import 'package:flutter/material.dart';
import 'package:travel_buddy/main.dart';
import 'package:travel_buddy/reg/login.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_buddy/screens/trips.dart';
import 'home.dart';
import 'profile.dart';
import 'upcoming.dart';
import 'chats.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  static const List<String> _titles = [
    'Home',
    'Trips',
    'Upcoming',
    'Chat',
    'Profile',
  ];
  static  List<Widget> _widgetOptions = <Widget>[
    Home(),
    TripScreen(),
    UpcomingScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_titles[_selectedIndex]), // Set dynamic title here
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _signOut,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Container(
            color: Colors.black,
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
                backgroundColor: Colors.black,
                color: Colors.white,
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
                    icon: LineIcons.calendarPlusAlt,
                    text: 'Upcoming',
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
