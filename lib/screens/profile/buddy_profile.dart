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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.buddy['avatar_url'] ?? ''),
                  backgroundColor: Colors.amber,
                  radius: screenWidth * 0.2,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Name: ${widget.buddy['full_name'] ?? 'N/A'}',
                style: TextStyle(fontSize: screenWidth * 0.05),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Username: ${widget.buddy['username'] ?? 'N/A'}',
                style: TextStyle(fontSize: screenWidth * 0.05),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Email: ${widget.buddy['email'] ?? 'N/A'}',
                style: TextStyle(fontSize: screenWidth * 0.05),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Mobile: ${widget.buddy['mobile'] ?? 'N/A'}',
                style: TextStyle(fontSize: screenWidth * 0.05),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Date of Birth: ${widget.buddy['dob'] ?? 'N/A'}',
                style: TextStyle(fontSize: screenWidth * 0.05),
              ),
              SizedBox(height: screenHeight * 0.01),
              
            ],
          ),
        ),
      ),
    );
  }
}
