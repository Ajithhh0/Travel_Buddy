import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_buddy/drawer_pages/documents.dart/documents.dart';
import 'package:travel_buddy/drawer_pages/sos/sos.dart';

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
            child: DrawerHeader(
              child: Image.asset('assets/icons/jeep_icon.png'),
            ),
          ),

          //settings
          const SizedBox(
            height: 8.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              title: const Text('Settings'),
              leading: const Icon(Icons.settings),
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              title: const Text('SOS'),
              leading: const Icon(Icons.sos),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Sos()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              title: const Text('Documents'),
              leading: const Icon(Icons.edit_document),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DocumentUpload()),
                );
              },
            ),
          ),

          
        ],
      ),
    );
  }
}
