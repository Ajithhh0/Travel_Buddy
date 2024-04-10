import 'package:flutter/material.dart';
import 'package:travel_buddy/screens/Packages_&_Offers/Hotels.dart';
import 'package:travel_buddy/screens/plan_a_journey/map/map_page.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 5.0, right: 8.0),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Transform.translate(
                      offset: Offset(-150.0 + 150.0 * _animation.value, 0.0),
                      child: Transform.rotate(
                        angle: 0.5 * 3.14 * 0.366 * _animation.value, // Adjust rotation here
                        child: Container(
                          height: 200, //image height and width
                          width: 200,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0),
                            ),
                            color: Colors.white,
                            image: DecorationImage(
                              image: AssetImage('assets/images/c1.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeTransition(
                          opacity: _animation,
                          child: const Text(
                            'Travel Buddy',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeTransition(
                          opacity: _animation,
                          child: const Text(
                            'Your Travel Partner',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0, ),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                color: Colors.amber,
              ),
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 20.0,
                crossAxisSpacing: 10.0,
                padding: const EdgeInsets.all(18.0),
                children: [
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(-1.0, 0.0),
                      end: Offset.zero,
                    ).animate(_controller),
                    child: FadeTransition(
                      opacity: _animation,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MapScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          backgroundColor: Colors.black,
                        ),
                        child: const Center(
                          child: Text(
                            'Plan a Journey',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(-1.0, 0.0),
                      end: Offset.zero,
                    ).animate(_controller),
                    child: FadeTransition(
                      opacity: _animation,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          backgroundColor: Colors.black,
                        ),
                        child: const Center(
                          child: Text(
                            'Join a Trip',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(-1.0, 0.0),
                      end: Offset.zero,
                    ).animate(_controller),
                    child: FadeTransition(
                      opacity: _animation,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HotelOffers()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          backgroundColor: Colors.black,
                        ),
                        child: const Center(
                          child: Text(
                            'Packages and Offers',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(-1.0, 0.0),
                      end: Offset.zero,
                    ).animate(_controller),
                    child: FadeTransition(
                      opacity: _animation,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          backgroundColor: Colors.black,
                        ),
                        child: const Center(
                          child: Text(
                            'Past Trips',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(-1.0, 0.0),
                      end: Offset.zero,
                    ).animate(_controller),
                    child: FadeTransition(
                      opacity: _animation,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          backgroundColor: Colors.black,
                        ),
                        child: const Center(
                          child: Text(
                            'Photos',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(-1.0, 0.0),
                      end: Offset.zero,
                    ).animate(_controller),
                    child: FadeTransition(
                      opacity: _animation,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          backgroundColor: Colors.black,
                        ),
                        child: const Center(
                          child: Text(
                            'Accounts',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
