class DirectionDetails
{
  String? distanceTextString;
  String? durationTextString;
  int? distanceValueDigits;
  int? durationValueDigits;
  String? encodedPoints;

  DirectionDetails({
    this.distanceTextString,
    this.durationTextString,
    this.distanceValueDigits,
    this.durationValueDigits,
    this.encodedPoints,
  });

  DirectionDetails.fromJson(Map<String, dynamic> json) {
    distanceTextString = json['routes'][0]['legs'][0]['distance']['text'];
    distanceValueDigits = json['routes'][0]['legs'][0]['distance']['value'];
    durationTextString = json['routes'][0]['legs'][0]['duration']['text'];
    durationValueDigits = json['routes'][0]['legs'][0]['duration']['value'];
    encodedPoints = json['routes'][0]['overview_polyline']['points'];
  }
}
