//import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:travel_buddy/address_model.dart';
import 'package:travel_buddy/app_info.dart';
import 'package:travel_buddy/global_var.dart';

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
      Position position, BuildContext context) async {
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

      Provider.of<AppInfo>(context, listen: false)
          .updateStartLocation(model);
    }

    return humanReadableAddress;
  }
}