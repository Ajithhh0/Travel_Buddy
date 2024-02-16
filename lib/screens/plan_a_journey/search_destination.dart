import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy/app_info.dart';
import 'package:travel_buddy/common_methods.dart';
import 'package:travel_buddy/global_var.dart';
import 'package:travel_buddy/prediction_place_ui.dart';
import 'package:travel_buddy/predictions.dart';

class SearchDestinationPage extends StatefulWidget {
  const SearchDestinationPage({Key? key}) : super(key: key);

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
          desiredAccuracy: LocationAccuracy.high);
      String userAddress = await CommonMethods
          .convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
              position, context);
      setState(() {
        startingTextEditingController.text = userAddress;
      });
    } catch (e) {
      print("Error getting user location: $e");
    }
  }

  searchLocation(String locationName, TextEditingController controller) async {
  if (locationName.length > 0) {
    String apiPlacesUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$locationName&key=$gMapKey";

    var responseFromPlacesAPI =
        await CommonMethods.sendRequestToAPI(apiPlacesUrl);

    if (responseFromPlacesAPI == "error") {
      return;
    }

    if (responseFromPlacesAPI["status"] == "OK") {
      var predictionResultInJson = responseFromPlacesAPI["predictions"];
      var predictionsList = (predictionResultInJson as List)
          .map((eachPlacePrediction) =>
              PredictionModel.fromJson(eachPlacePrediction))
          .toList();

      if (controller == startingTextEditingController) {
        setState(() {
          startingPredictionsPlacesList = predictionsList;
        });
      } else {
        setState(() {
          destinationPredictionsPlacesList = predictionsList;
        });
      }
    }
  }
  if (locationName.isEmpty) {
    setState(() {
      startingPredictionsPlacesList.clear();
      destinationPredictionsPlacesList.clear();
    });
    return;
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
                height: 230,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
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
                                    searchLocation(value, startingTextEditingController);
                                  },
                                  decoration: const InputDecoration(
                                      hintText: "Starting From ?",
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
                                    searchLocation(value, destinationTextEditingController);
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListView.separated(
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              child: PredictionPlaceUI(
                predictedPlaceData: destinationPredictionsPlacesList[index],
                textFieldController: destinationTextEditingController,
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) => const SizedBox(
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListView.separated(
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              child: PredictionPlaceUI(
                predictedPlaceData: startingPredictionsPlacesList[index],
                textFieldController: startingTextEditingController,
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) => const SizedBox(
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