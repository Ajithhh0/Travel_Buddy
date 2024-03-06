import 'dart:async';

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
            startingGeoGraphicCoOrdinates, destinationGeoGraphicCoOrdinates);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Your Journey'),
        actions: [
          if (tripDirectionDetailsInfo != null)
            IconButton(
              onPressed: () {
               Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) {
      TripDetails? tripDetails =
          Provider.of<TripDetailsProvider>(context, listen: false).tripDetails;
          
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
            padding: const EdgeInsets.only(top: 26),
            initialCameraPosition: initialCameraPosition,
            mapType: MapType.normal,
            myLocationEnabled: true,
            polylines: polylineSet,
            markers: markerSet,
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
                        backgroundColor: Colors.grey,
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
    );
  }
}
