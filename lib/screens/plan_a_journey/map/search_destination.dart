import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy/misc/app_info.dart';
import 'package:travel_buddy/misc/common_methods.dart';
import 'package:travel_buddy/misc/global_var.dart';
import 'package:travel_buddy/misc/prediction_place_ui.dart';
import 'package:travel_buddy/misc/predictions.dart';

import 'package:travel_buddy/screens/plan_a_journey/trip_plan.dart';

class SearchDestinationPage extends StatefulWidget {
  final VoidCallback onGoButtonPressed;

  const SearchDestinationPage({Key? key, required this.onGoButtonPressed})
      : super(key: key);

  @override
  State<SearchDestinationPage> createState() => _SearchDestinationPageState();
}

class _SearchDestinationPageState extends State<SearchDestinationPage> {
  TextEditingController startingTextEditingController = TextEditingController();
  TextEditingController destinationTextEditingController =
      TextEditingController();

  List<PredictionModel> destinationPredictionsPlacesList = [];
  List<PredictionModel> startingPredictionsPlacesList = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      String userAddress = await CommonMethods
          .convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
              position, context, true);
      setState(() {
        startingTextEditingController.text = userAddress;
      });
    } catch (e) {
      print("Error getting user location: $e");
    }
  }

  searchLocation(String locationName, TextEditingController controller) async {
    if (locationName.isEmpty) {
      setState(() {
        startingPredictionsPlacesList.clear();
        destinationPredictionsPlacesList.clear();
      });
      return;
    }

    String apiPlacesUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$locationName&key=$gMapKey";

    var responseFromPlacesAPI =
        await CommonMethods.sendRequestToAPI(apiPlacesUrl);

    if (responseFromPlacesAPI == "error") {
      // Handle API request error
      print("Error: Failed to fetch predictions from Places API");
      return;
    }

    if (responseFromPlacesAPI["status"] != "OK") {
      // Handle API response status other than "OK"
      print("Error: Unexpected status from Places API");
      return;
    }

    var predictionResultInJson = responseFromPlacesAPI["predictions"];
    if (predictionResultInJson == null || !(predictionResultInJson is List)) {
      // Handle unexpected data format in API response
      print("Error: Unexpected data format in predictions response");
      return;
    }

    var predictionsList = predictionResultInJson
        .map((eachPlacePrediction) =>
            PredictionModel.fromJson(eachPlacePrediction))
        .toList();

    // Update predictions list with latitude and longitude
    List<PredictionModel> updatedPredictionsList = [];
    for (var prediction in predictionsList) {
      if (prediction.latitude != null && prediction.longitude != null) {
        updatedPredictionsList.add(prediction);
      } else {
        // Fetch latitude and longitude for the place
        String placeId = prediction.place_id ?? "";
        if (placeId.isNotEmpty) {
          String placeDetailsUrl =
              "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$gMapKey";
          var response = await CommonMethods.sendRequestToAPI(placeDetailsUrl);
          if (response != null &&
              response["status"] == "OK" &&
              response["result"] != null &&
              response["result"]["geometry"] != null &&
              response["result"]["geometry"]["location"] != null) {
            var location = response["result"]["geometry"]["location"];
            prediction.latitude = location["lat"];
            prediction.longitude = location["lng"];
            updatedPredictionsList.add(prediction);
          }
        }
      }
    }

    setState(() {
      if (controller == startingTextEditingController) {
        startingPredictionsPlacesList = updatedPredictionsList;
      } else {
        destinationPredictionsPlacesList = updatedPredictionsList;
      }
    });
  }

  void _handleGoButtonPressed() {
    // Call the onGoButtonPressed callback if provided
    if (widget.onGoButtonPressed != null) {
      widget.onGoButtonPressed!();

      
      Navigator.pop(context);

      //     Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => TripPlanning(tripDetails: tripDetails!)),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    String userAddress = Provider.of<AppInfo>(context, listen: false)
            .startLocation
            ?.humanReadableAddress ??
        "Not Available";

    // startingTextEditingController.text = userAddress;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              
              elevation: 10,
              child: Container(
                height: 235,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 24, top: 48, right: 24, bottom: 20),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 6,
                      ),
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                          ),
                          const Center(
                            child: Text(
                              "Plan Your Route",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[350],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: TextField(
                                  controller: startingTextEditingController,
                                  onChanged: (value) {
                                    searchLocation(
                                        value, startingTextEditingController);
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "Starting From ?",
                                    fillColor: Colors.white12,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 11, top: 9, bottom: 9),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 11,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[350],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: TextField(
                                  controller: destinationTextEditingController,
                                  onChanged: (value) {
                                    searchLocation(value,
                                        destinationTextEditingController);
                                  },
                                  decoration: const InputDecoration(
                                      hintText: "Destination",
                                      fillColor: Colors.white12,
                                      filled: true,
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(
                                          left: 11, top: 9, bottom: 9)),
                                ),
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _handleGoButtonPressed,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Go'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //prediction_result_destination
            (destinationPredictionsPlacesList.length > 0)
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 3,
                          child: PredictionPlaceUI(
                            predictedPlaceData:
                                destinationPredictionsPlacesList[index],
                            textFieldController:
                                destinationTextEditingController,
                            isStart: false,
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(
                        height: 2,
                      ),
                      itemCount: destinationPredictionsPlacesList.length,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                    ),
                  )
                : Container(),
            (startingPredictionsPlacesList.length > 0)
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 3,
                          child: PredictionPlaceUI(
                            predictedPlaceData:
                                startingPredictionsPlacesList[index],
                            textFieldController: startingTextEditingController,
                            isStart: true,
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(
                        height: 2,
                      ),
                      itemCount: startingPredictionsPlacesList.length,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
