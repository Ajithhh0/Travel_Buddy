import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy/misc/app_info.dart';
import 'package:travel_buddy/misc/common_methods.dart';
import 'package:travel_buddy/misc/detailsvar.dart';
import 'package:travel_buddy/misc/tripdetailsprovider.dart';
import 'package:travel_buddy/screens/plan_a_journey/models/direction_details.dart';
import 'package:travel_buddy/misc/global_var.dart';
import 'package:travel_buddy/misc/loading.dart';
import 'package:travel_buddy/screens/plan_a_journey/map/search_destination.dart';
import 'package:travel_buddy/screens/plan_a_journey/models/trip_model.dart';
import 'package:travel_buddy/screens/plan_a_journey/trip_plan.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> gMapCompleterController =
      Completer<GoogleMapController>();

  GoogleMapController? controllerGoogleMap;
  Position? currentPositonOfUser;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  CommonMethods cMethods = CommonMethods();
  double searchContainerHeight = 276;
  double bottomMapPadding = 0;
  DirectionDetails? tripDirectionDetailsInfo;
  List<LatLng> polylineCoOrdinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  bool isCustomizingRoute = false;
  List<Marker> customMarkers = [];
  List<LatLng> customWaypoints = [];

  @override
  void initState() {
    super.initState();
    checkLocationServices();
  }

  Future<void> checkLocationServices() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Location Services Disabled'),
            content:
                const Text('Please enable location services for this app.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied.
          // Disable location features of your app or show a message to the user.
        }
      }
    }
  }

  getCurrentLiveLocationUser() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositonOfUser = positionOfUser;

    LatLng positionOfUserInLatLng =
        LatLng(currentPositonOfUser!.latitude, currentPositonOfUser!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: positionOfUserInLatLng, zoom: 15);

    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  retrieveDirectionDetails() async {
    TripDetails _createTripDetails() {
      // Create TripDetails object based on your requirements
      return TripDetails(
        tripName: "tripName",
        directionDetails: tripDirectionDetailsInfo,
        members: [],
        budget: Budget(amount: 0.0), // Initialize with 0 budget
        expenses: [],
      );
    }

    Provider.of<TripDetailsProvider>(context, listen: false)
        .setTripDetails(_createTripDetails());

    var startingLocation =
        Provider.of<AppInfo>(context, listen: false).startLocation;
    var destinationLocation =
        Provider.of<AppInfo>(context, listen: false).destinationLocation;

    if (startingLocation == null || destinationLocation == null) {
      //error if no location selected
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Please select both starting and destination locations.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    var startingGeoGraphicCoOrdinates = LatLng(
        startingLocation!.latitudePosition!,
        startingLocation.longitudePosition!);
    var destinationGeoGraphicCoOrdinates = LatLng(
        destinationLocation!.latitudePosition!,
        destinationLocation.longitudePosition!);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Getting directions..."),
    );

    ///Directions API
    var detailsFromDirectionAPI =
        await CommonMethods.getDirectionDetailsFromAPI(
            startingGeoGraphicCoOrdinates, destinationGeoGraphicCoOrdinates, gMapKey);
    setState(() {
      tripDirectionDetailsInfo = detailsFromDirectionAPI;
    });

    DetailsVar details = DetailsVar(
      distanceTextString: tripDirectionDetailsInfo!.distanceTextString,
      durationTextString: tripDirectionDetailsInfo!.durationTextString,
      distanceValueDigits: tripDirectionDetailsInfo!.distanceValueDigits,
      durationValueDigits: tripDirectionDetailsInfo!.durationValueDigits,
      encodedPoints: tripDirectionDetailsInfo!.encodedPoints,
    );

    Navigator.pop(context);

    PolylinePoints pointsPolyline = PolylinePoints();
    List<PointLatLng> latLngPointsFromStartToDestination =
        pointsPolyline.decodePolyline(tripDirectionDetailsInfo!.encodedPoints!);

    polylineCoOrdinates.clear();
    if (latLngPointsFromStartToDestination.isNotEmpty) {
      latLngPointsFromStartToDestination.forEach((PointLatLng latLngPoint) {
        polylineCoOrdinates
            .add(LatLng(latLngPoint.latitude, latLngPoint.longitude));
      });
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId("polylineID"),
        color: Colors.blue,
        points: polylineCoOrdinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    //fit the polyline into the map
    LatLngBounds boundsLatLng;
    if (startingGeoGraphicCoOrdinates.latitude >
            destinationGeoGraphicCoOrdinates.latitude &&
        startingGeoGraphicCoOrdinates.longitude >
            destinationGeoGraphicCoOrdinates.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: destinationGeoGraphicCoOrdinates,
        northeast: startingGeoGraphicCoOrdinates,
      );
    } else if (startingGeoGraphicCoOrdinates.longitude >
        destinationGeoGraphicCoOrdinates.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(startingGeoGraphicCoOrdinates.latitude,
            destinationGeoGraphicCoOrdinates.longitude),
        northeast: LatLng(destinationGeoGraphicCoOrdinates.latitude,
            startingGeoGraphicCoOrdinates.longitude),
      );
    } else if (startingGeoGraphicCoOrdinates.latitude >
        destinationGeoGraphicCoOrdinates.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationGeoGraphicCoOrdinates.latitude,
            startingGeoGraphicCoOrdinates.longitude),
        northeast: LatLng(startingGeoGraphicCoOrdinates.latitude,
            destinationGeoGraphicCoOrdinates.longitude),
      );
    } else {
      boundsLatLng = LatLngBounds(
        southwest: startingGeoGraphicCoOrdinates,
        northeast: destinationGeoGraphicCoOrdinates,
      );
    }

    controllerGoogleMap!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 72));

    //add markers to pickup and dropOffDestination points
    Marker pickUpPointMarker = Marker(
      markerId: const MarkerId("startingPointMarkerID"),
      position: startingGeoGraphicCoOrdinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
          title: startingLocation.placeName, snippet: "Pickup Location"),
    );

    Marker dropOffDestinationPointMarker = Marker(
      markerId: const MarkerId("destinationPointMarkerID"),
      position: destinationGeoGraphicCoOrdinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
          title: destinationLocation.placeName,
          snippet: "Destination Location"),
    );

    setState(() {
      markerSet.add(pickUpPointMarker);
      markerSet.add(dropOffDestinationPointMarker);
    });

    //add circles to pickup and dropOffDestination points
    Circle startingPointCircle = Circle(
      circleId: const CircleId('pickupCircleID'),
      strokeColor: Colors.blue,
      strokeWidth: 4,
      radius: 14,
      center: startingGeoGraphicCoOrdinates,
      fillColor: Colors.green,
    );

    Circle destinationPointCircle = Circle(
      circleId: const CircleId('dropOffDestinationCircleID'),
      strokeColor: Colors.blue,
      strokeWidth: 4,
      radius: 14,
      center: destinationGeoGraphicCoOrdinates,
      fillColor: Colors.pink,
    );

    setState(() {
      circleSet.add(startingPointCircle);
      circleSet.add(destinationPointCircle);
    });
  }
   
   void _handleMapTap(LatLng tapLocation) {
  if (isCustomizingRoute) {
    setState(() {
      // Find the index where to insert the new marker
      int insertionIndex = 0;
      for (int i = 0; i < customMarkers.length; i++) {
        if (customMarkers[i].position.latitude > tapLocation.latitude) {
          insertionIndex = i;
          break;
        }
      }

      // Insert the new marker at the appropriate index
      customMarkers.insert(
        insertionIndex,
        Marker(
          markerId: MarkerId('custom_$insertionIndex'),
          position: tapLocation,
          infoWindow: InfoWindow(title: 'Custom Waypoint $insertionIndex'),
        ),
      );
      customWaypoints.insert(insertionIndex, tapLocation);

      _updatePolylineWithCustomWaypoints();
    });
  }
}

void _updatePolylineWithCustomWaypoints() async {
  final startLocation = Provider.of<AppInfo>(context, listen: false).startLocation;
  final destinationLocation = Provider.of<AppInfo>(context, listen: false).destinationLocation;

  if (startLocation == null || destinationLocation == null) {
    return;
  }

  polylineCoOrdinates.clear();

  LatLng origin = LatLng(startLocation.latitudePosition!, startLocation.longitudePosition!);
  polylineCoOrdinates.add(origin);

  for (int i = 0; i < customWaypoints.length; i++) {
    LatLng destination = customWaypoints[i];
    String directionsUrl = 'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$gMapKey';

    var responseFromDirectionsAPI = await CommonMethods.sendRequestToAPI(directionsUrl);

    if (responseFromDirectionsAPI != "error") {
      DirectionDetails detailsModel = DirectionDetails();

      detailsModel.distanceTextString = responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["text"];
      detailsModel.distanceValueDigits = responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["value"];

      detailsModel.durationTextString = responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["text"];
      detailsModel.durationValueDigits = responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["value"];

      detailsModel.encodedPoints = responseFromDirectionsAPI["routes"][0]["overview_polyline"]["points"];

      PolylinePoints pointsPolyline = PolylinePoints();
      List<PointLatLng> latLngPointsFromRoute = pointsPolyline.decodePolyline(detailsModel.encodedPoints!);

      if (latLngPointsFromRoute.isNotEmpty) {
        latLngPointsFromRoute.forEach((PointLatLng latLngPoint) {
          polylineCoOrdinates.add(LatLng(latLngPoint.latitude, latLngPoint.longitude));
        });
      }

      origin = destination;
    }
  }

  LatLng destinationCoordinates = LatLng(destinationLocation.latitudePosition!, destinationLocation.longitudePosition!);
  polylineCoOrdinates.add(destinationCoordinates);

   if (polylineCoOrdinates.length >= 2) {
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId("polylineID"),
        color: Colors.blue,
        points: polylineCoOrdinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    // Ensure that the southwest and northeast coordinates are correct
    double minLatitude = polylineCoOrdinates.map((p) => p.latitude).reduce(min);
    double maxLatitude = polylineCoOrdinates.map((p) => p.latitude).reduce(max);
    double minLongitude = polylineCoOrdinates.map((p) => p.longitude).reduce(min);
    double maxLongitude = polylineCoOrdinates.map((p) => p.longitude).reduce(max);

    LatLngBounds boundsLatLng = LatLngBounds(
      southwest: LatLng(minLatitude, minLongitude),
      northeast: LatLng(maxLatitude, maxLongitude),
    );

    controllerGoogleMap!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 72));
  }
}

  void _clearCustomRoute() {
  setState(() {
    customMarkers.clear();
    _updatePolylineWithCustomWaypoints();
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Plan Your Journey'),
        centerTitle: true,
        // shape: const RoundedRectangleBorder(
        //   borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        // ),
        backgroundColor: Colors.white,
        actions: [
          if (tripDirectionDetailsInfo != null)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      TripDetails? tripDetails =
                          Provider.of<TripDetailsProvider>(context,
                                  listen: false)
                              .tripDetails;

                      return tripDetails != null
                          ? TripPlanning(tripDetails: tripDetails)
                          : Container(); // or any other fallback widget or action
                    },
                  ),
                );
              },
              icon: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Add Trip'),
                  Icon(Icons.add),
                ],
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onTap: _handleMapTap,
            padding: const EdgeInsets.only(top: 26),
            initialCameraPosition: initialCameraPosition,
            mapType: MapType.normal,
            myLocationEnabled: true,
            polylines: polylineSet,
            markers: Set.from(markerSet)..addAll(customMarkers),
            // circles: circleSet,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;

              gMapCompleterController.complete(controllerGoogleMap);

              setState(() {
                bottomMapPadding = 271;
              });

              getCurrentLiveLocationUser();
            },
          ),
           if(isCustomizingRoute)
              Positioned(
                 bottom: 600,
                 right: 260,
                child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: _clearCustomRoute,
                  child: const Icon(Icons.clear),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      isCustomizingRoute = false;
                      customMarkers.clear();
                      _updatePolylineWithCustomWaypoints();
                    });
                  },
                  child: const Icon(Icons.done),
                ),
              ],
            ),
          ),
                 


          Positioned(
            top: 36,
            left: 19,
            child: GestureDetector(
              onTap: () {
                sKey.currentState!.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                // child: const CircleAvatar(
                //   backgroundColor: Colors.grey,
                //   radius: 20,
                //   child: Icon(
                //     Icons.menu,
                //     color: Colors.black87,
                //   ),
                // ),
              ),
            ),
          ),

          ///search location icon button
          Positioned(
            left: 0,
            right: 280,
            bottom: -80,
            child: Container(
              height: searchContainerHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () { 
                      print('object');
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) =>
                                  SearchDestinationPage(onGoButtonPressed: () {
                                    // Call the retrieveDirectionDetails() method here
                                    retrieveDirectionDetails();
                                  })));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(24)),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
  children: [
    Positioned(
      bottom: 80,
      right: 1,
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            isCustomizingRoute = true;
          });
        },
        child: Icon(Icons.edit),
      ),
    ),
  ],
),

    );
  }
}
