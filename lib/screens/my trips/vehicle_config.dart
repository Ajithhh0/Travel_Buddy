import 'package:flutter/material.dart';

class VehicleConfig extends StatefulWidget {
  const VehicleConfig({Key? key}) : super(key: key);

  @override
  State<VehicleConfig> createState() => _VehicleConfigState();
}

class _VehicleConfigState extends State<VehicleConfig> {
  // Map of icon paths and their corresponding vehicle names
  final Map<String, String> _iconNames = {
    'c4.png': 'Car',
    'c5.png': 'SUV',
    'b1.png': 'Bike',
    'm2.png': 'Motor Bike',
  };

  // List of icon paths
  final List<String> _iconPaths = ['c4.png', 'c5.png', 'm2.png', 'b1.png'];

  // Map to store the selected icon and its count
  Map<String, int> _selectedIcons = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: _iconPaths.map((iconPath) {
            int count = _selectedIcons.containsKey(iconPath) ? _selectedIcons[iconPath]! : 0;
            return ListTile(
              leading: Image.asset('assets/images/$iconPath'),
              title: Row(
                children: [
                  Text('${_iconNames[iconPath]}'),
                  Spacer(),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (_selectedIcons.containsKey(iconPath)) {
                              if (_selectedIcons[iconPath]! > 0) {
                                _selectedIcons[iconPath] = _selectedIcons[iconPath]! - 1;
                              }
                            }
                          });
                        },
                      ),
                      Text('$count'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            if (_selectedIcons.containsKey(iconPath)) {
                              _selectedIcons[iconPath] = _selectedIcons[iconPath]! + 1;
                            } else {
                              _selectedIcons[iconPath] = 1;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
