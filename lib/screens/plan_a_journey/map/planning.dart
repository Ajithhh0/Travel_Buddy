import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class PlanningScreen extends StatefulWidget {
  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(25.2854, 51.5310),
    zoom: 12,
  );

  bool _isSearching = false;
  List<String> listForPlaces = [];
  final TextEditingController _tcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getUserLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print('error $error');
    });

    final Position position = await Geolocator.getCurrentPosition();
    _animateToPosition(position.latitude, position.longitude, 15);
    _addMarker(LatLng(position.latitude, position.longitude), "You");
  }

  Future<void> _searchPlaces(String input) async {
    if (input.isEmpty) {
      setState(() {
        _isSearching = false;
        listForPlaces.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final String googlePlacesApiKey = 'AIzaSyD0AiYo5-mCiOEHs2CRB5V1WpDptOtVzGc';
    final String groundURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    final String request = '$groundURL?input=$input&key=$googlePlacesApiKey'; 

    final response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final predictions =
          jsonDecode(response.body)['predictions'] as List<dynamic>;
      setState(() {
        listForPlaces = predictions
            .map((prediction) => prediction['description'] as String)
            .toList();
      });
    } else {
      throw Exception('Failed to load places');
    }
  }

  Future<void> _moveToPlace(String place) async {
    try {
      final query = await locationFromAddress(place);
      final LatLng targetLatLng = LatLng(query[0].latitude, query[0].longitude);
      _addMarker(targetLatLng, place);
      _animateToPosition(query[0].latitude, query[0].longitude, 15);
      _showBottomSheet(place);
    } catch (e) {
      print("Error: $e");
    }
  }

  void _animateToPosition(
      double latitude, double longitude, double zoom) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: zoom,
    )));
  }

  void _addMarker(LatLng position, String title) {
    setState(() {
      listForPlaces.clear(); // Clear the list of places suggestions
      markers.clear(); // Clear any previous markers
      markers.add(
        Marker(
          markerId: MarkerId('SelectedPlace'),
          position: position,
          infoWindow: InfoWindow(
            title: title,
          ),
        ),
      );
    });
  }

  void _showBottomSheet(String place) async {
    showModalBottomSheet(
      context: context,
      enableDrag: true, // Add this line to disable the modal barrier
      builder: (context) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.directions),
                title: Text('Directions to $place'),
                onTap: () async {
                  // Implement your logic for directions
                  Navigator.pop(context);
                  _getDirections(place);
                },
              ),
              ListTile(
                leading: const Icon(Icons.navigation),
                title: Text('Go now to $place'),
                onTap: () async {
                  // Implement your logic for navigation
                  Navigator.pop(context);
                  await _addMarkersAndPolyline(place);
                },
              ),
              // Add more ListTile widgets for additional actions if needed
            ],
          ),
        );
      },
    );
  }

  Future<void> _addMarkersAndPolyline(String place) async {
    try {
      final Position userPosition = await Geolocator.getCurrentPosition();
      final List<Location> locations = await locationFromAddress(place);
      final LatLng targetLatLng = LatLng(locations.first.latitude, locations.first.longitude);

      // Add user's location marker
      _addMarker(LatLng(userPosition.latitude, userPosition.longitude), "You");
      // Add place marker
      _addMarker(targetLatLng, place);

      // Draw polyline
      _getDirections(place);
    } catch (e) {
      print("Error: $e");
    }
  }


  List<Marker> markers = [];
  List<Polyline> polylines = [];

  void _getDirections(String destination) async {
    final Position currentPosition = await Geolocator.getCurrentPosition();
    final List<Location> locations = await locationFromAddress(destination);
    final LatLng destinationLatLng = LatLng(locations.first.latitude, locations.first.longitude);
    const String apiKey = 'AIzaSyD0AiYo5-mCiOEHs2CRB5V1WpDptOtVzGc';
    final String apiUrl = 'https://maps.googleapis.com/maps/api/directions/json?origin=${currentPosition.latitude},${currentPosition.longitude}&destination=${destinationLatLng.latitude},${destinationLatLng.longitude}&key=$apiKey';
    
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> routes = data['routes'];
      if (routes.isNotEmpty) {
        final List<dynamic> legs = routes[0]['legs'];
        final List<LatLng> points = <LatLng>[];
        for (var i = 0; i < legs.length; i++) {
          final List<dynamic> steps = legs[i]['steps'];
          for (var j = 0; j < steps.length; j++) {
            final List<dynamic> latLngs = PolylinePoints().decodePolyline(steps[j]['polyline']['points']);
            for (var latLng in latLngs) {
              points.add(latLng);
            }
          }
        }

        setState(() {
          polylines.add(
            Polyline(
              polylineId: PolylineId('poly'),
              color: Colors.blue,
              width: 5,
              points: points,
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Your Journey'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            mapType: MapType.normal,
            markers: Set<Marker>.of(markers),
            polylines: Set<Polyline>.of(polylines),
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
              await _getUserLocation(); // Get the user's location
            },
            onTap: (LatLng latLng) {
              _addMarker(latLng, 'Custom Marker');
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _tcontroller,
                      decoration: const InputDecoration(
                        hintText: 'Search here...',
                        border: InputBorder.none,
                      ),
                      onChanged: (input) => _searchPlaces(input),
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
          if (_isSearching)
            Positioned(
              top: 90,
              left: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: const Border(
                    left: BorderSide(
                      color: Colors.blue,
                      width: 3,
                    ),
                  ),
                ),
                child: ListView.builder(
                  itemCount: listForPlaces.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () async {
                        String selectedPlace = listForPlaces[index];
                        await _moveToPlace(selectedPlace);
                      },
                      title: Text(listForPlaces[index]),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
