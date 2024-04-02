import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          //logo
          Center(
            child: DrawerHeader(child: Image.asset('assets/icons/jeep_icon.png'),
          ),
        ),

          //settings
          const SizedBox(height: 8.0,),
        Padding(padding: const EdgeInsets.only(left: 25.0),
        child: ListTile(
          title: const Text('Settings'),
          leading: const Icon(Icons.settings),
          onTap: (){},
        ),
        ),

          //logout
        ],
      ),
    );
  }
}