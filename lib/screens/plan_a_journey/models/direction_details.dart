import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionDetails {
  String? distanceTextString;
  String? durationTextString;
  int? distanceValueDigits;
  int? durationValueDigits;
  String? encodedPoints;
  LatLngBounds? bounds; // Add bounds property

  DirectionDetails({
    this.distanceTextString,
    this.durationTextString,
    this.distanceValueDigits,
    this.durationValueDigits,
    this.encodedPoints,
    this.bounds, // Initialize bounds in the constructor
  });

  DirectionDetails.fromJson(Map<String, dynamic> json) {
    distanceTextString = json['routes'][0]['legs'][0]['distance']['text'];
    distanceValueDigits = json['routes'][0]['legs'][0]['distance']['value'];
    durationTextString = json['routes'][0]['legs'][0]['duration']['text'];
    durationValueDigits = json['routes'][0]['legs'][0]['duration']['value'];
    encodedPoints = json['routes'][0]['overview_polyline']['points'];
    bounds = LatLngBounds(
      southwest: LatLng(
        json['routes'][0]['bounds']['southwest']['lat'],
        json['routes'][0]['bounds']['southwest']['lng'],
      ),
      northeast: LatLng(
        json['routes'][0]['bounds']['northeast']['lat'],
        json['routes'][0]['bounds']['northeast']['lng'],
      ),
    );
  }
}
