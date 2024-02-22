import 'package:flutter/material.dart';

class TripPlanning extends StatefulWidget {
  const TripPlanning({super.key});

  @override
  State<TripPlanning> createState() => _TripPlanningState();
}

class _TripPlanningState extends State<TripPlanning> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(title: const Text('Trip Planning'),),
    );
  }
}