import 'package:flutter/material.dart';

class BuddyProfilePage extends StatefulWidget {
  final Map<String, dynamic> buddy;

  const BuddyProfilePage({Key? key, required this.buddy}) : super(key: key);

  @override
  _BuddyProfilePageState createState() => _BuddyProfilePageState();
}

class _BuddyProfilePageState extends State<BuddyProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buddy Profile'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.buddy['avatar_url'] ?? ''),
                  backgroundColor: Colors.amber, // Placeholder color
                  radius: 50,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${widget.buddy['full_name'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Username: ${widget.buddy['username'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Email: ${widget.buddy['email'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Mobile: ${widget.buddy['mobile'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Date of Birth: ${widget.buddy['dob'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            // You can add more details here
          ],
        ),
      ),
    );
  }
}
