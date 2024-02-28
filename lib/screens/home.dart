import 'package:flutter/material.dart';
//import 'package:travel_buddy/altmap/screens/mapScreen.dart';
import 'package:travel_buddy/screens/plan_a_journey/map/map_page.dart';


//import 'package:travel_buddy/screens/plan_a_journey/planning.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.amber,
        shadowColor: Colors.yellow,
        elevation: 20,
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(900),bottomRight: Radius.circular(00),),
          child: Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/jeep00.jpg"),
          fit: BoxFit.fill,
          alignment: Alignment.center ),) ,),
        ),
        shape: const RoundedRectangleBorder(
          
          // side: BorderSide(
          //   width: 10,
          //   color: Colors.amber,
          //   ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(800),bottomRight: Radius.circular(000),),
            
        ),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(170),
        child: SizedBox(),),
        ),
      body: GridView.count(
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
          
          MaterialPageRoute(builder: (context) => MapScreen()),
          
        );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15.0),
                ), backgroundColor: Colors.amber,
              ),
              child: const Text(
                'Plan a Journey',
                style: TextStyle(color: Colors.black),
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
                ), backgroundColor: Colors.amber,
              ),
              child: const Text(
                'Join a Trip',
                style: TextStyle(color: Colors.black),
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
                ), backgroundColor: Colors.amber,
              ),
              child: const Text(
                'Packages and Offers',
                style: TextStyle(color: Colors.black),
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
                ), backgroundColor: Colors.amber,
              ),
              child: const Text(
                'Accounts',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
         
        ],
      ),
    );
  }
}
