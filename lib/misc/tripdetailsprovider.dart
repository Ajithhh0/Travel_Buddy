import 'package:flutter/material.dart';
import 'package:travel_buddy/screens/plan_a_journey/models/trip_model.dart';

class TripDetailsProvider extends ChangeNotifier {
  TripDetails? _tripDetails;

  TripDetails? get tripDetails => _tripDetails;

  void setTripDetails(TripDetails tripDetails) {
    _tripDetails = tripDetails;
    notifyListeners();
  }
}
