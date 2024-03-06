//import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:travel_buddy/misc/address_model.dart';
import 'package:travel_buddy/misc/app_info.dart';
import 'package:travel_buddy/screens/plan_a_journey/models/direction_details.dart';
import 'package:travel_buddy/misc/global_var.dart';

class CommonMethods {
  // checkConnectivity(BuildContext context) async
  // {
  //   var connectionResult = await Connectivity().checkConnectivity();

  //   if(connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi)
  //   {
  //     if(!context.mounted) return;
  //     displaySnackBar("your Internet is not Available. Check your connection. Try Again.", context);
  //   }
  // }

  displaySnackBar(String messageText, BuildContext context) {
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static sendRequestToAPI(String apiUrl) async {
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));

    try {
      if (responseFromAPI.statusCode == 200) {
        String dataFromApi = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded;
      } else {
        return "error";
      }
    } catch (errorMsg) {
      return "error";
    }
  }

  static Future<String> convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
      Position position, BuildContext context, bool isStartLoc) async {
    String humanReadableAddress = "";
    String apiGeoCodingUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$gMapKey";

    var responseFromAPI = await sendRequestToAPI(apiGeoCodingUrl);

    if (responseFromAPI != "error") {
      humanReadableAddress = responseFromAPI["results"][0]["formatted_address"];
      print("humanReadableAddress = " + humanReadableAddress);

      AddressModel model = AddressModel();

      model.humanReadableAddress = humanReadableAddress;
      model.longitudePosition = position.longitude;
      model.latitudePosition = position.latitude;

      

      if (isStartLoc) {
        Provider.of<AppInfo>(context, listen: false).updateStartLocation(model);
      } else {
        Provider.of<AppInfo>(context, listen: false)
            .updateDestinationLocation(model);
      }
    }

    return humanReadableAddress;
  }

  //directions_api
  static Future<DirectionDetails?> getDirectionDetailsFromAPI(
      LatLng source, LatLng destination) async {
    String urlDirectionsAPI =
        "https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$gMapKey";

    print(' API KEY: ${urlDirectionsAPI}');

    var responseFromDirectionsAPI = await sendRequestToAPI(urlDirectionsAPI);

    if (responseFromDirectionsAPI == "error") {
      return null;
    }

    DirectionDetails detailsModel = DirectionDetails();

    if (responseFromDirectionsAPI["routes"].isEmpty) {
      print('Routes Empty');
    }

    detailsModel.distanceTextString =
        responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["text"];
    detailsModel.distanceValueDigits =
        responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["value"];

    detailsModel.durationTextString =
        responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["text"];
    detailsModel.durationValueDigits =
        responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["value"];

    detailsModel.encodedPoints =
        responseFromDirectionsAPI["routes"][0]["overview_polyline"]["points"];

    return detailsModel;
  }
}
