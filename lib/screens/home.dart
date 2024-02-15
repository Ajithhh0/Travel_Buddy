import 'package:flutter/material.dart';
import 'package:travel_buddy/screens/plan_a_journey/map_page.dart';

import 'package:travel_buddy/screens/plan_a_journey/planning.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 20.0,
      crossAxisSpacing: 20.0,
      padding: const EdgeInsets.all(20.0),
      children: [
        Container(
          height: 100,
          width: 100,
          child: ElevatedButton(
            onPressed: () {
             Navigator.push(
          context,
        //MaterialPageRoute(builder: (context) => PlanningScreen()),
        MaterialPageRoute(builder: (context) => MapScreen()),
  );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15.0),
              ),
              primary: Colors.blue,
            ),
            child: const Text(
              'Plan a Journey',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Container(
          height: 100,
          width: 100,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              primary: Colors.blue,
            ),
            child: const Text(
              'Plans',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Container(
          height: 100,
          width: 100,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              primary: Colors.blue,
            ),
            child: const Text(
              'Join a Trip',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Container(
          height: 100,
          width: 100,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              primary: Colors.blue,
            ),
            child: const Text(
              'Events',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Container(
          height: 100,
          width: 100,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              primary: Colors.blue,
            ),
            child: const Text(
              'Packages and Offers',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
        Container(
          height: 100,
          width: 100,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              primary: Colors.blue,
            ),
            child: const Text(
              'Accounts',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Container(
          height: 100,
          width: 100,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              primary: Colors.blue,
            ),
            child: const Text(
              'Photos',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Container(
          height: 100,
          width: 100,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              primary: Colors.blue,
            ),
            child: const Text(
              'Past Trips',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
