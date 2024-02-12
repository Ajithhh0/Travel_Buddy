import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

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

  final List<Marker> markers = [];
  final List<Marker> markerList = [
    const Marker(
      markerId: MarkerId('First'),
      position: LatLng(25.2854, 51.5310),
      infoWindow: InfoWindow(
        title: 'My Postion',
      ),
    ),
    const Marker(
      markerId: MarkerId('Second'),
      position: LatLng(24.7502, 50.8522),
      infoWindow: InfoWindow(
        title: 'Border',
      ),
    ),
    const Marker(
      markerId: MarkerId('Third'),
      position: LatLng(25.2426, 51.4467),
      infoWindow: InfoWindow(
        title: 'Stop',
      ),
    ),
  ];

  bool _isSearching = false;
  List<String> listForPlaces = [];
  final TextEditingController _tcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    markers.addAll(markerList);
  }

  Future<void> _getUserLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print('error $error');
    });

    final Position position = await Geolocator.getCurrentPosition();
    _addUserLocationMarker(position.latitude, position.longitude);
  }

  void _addUserLocationMarker(double latitude, double longitude) {
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId('UserLocation'),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: 'My Location',
          ),
        ),
      );
    });
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
    final String groundURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    final String request = '$groundURL?input=$input&key=$googlePlacesApiKey';

    final response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final predictions = jsonDecode(response.body)['predictions'] as List<dynamic>;
      setState(() {
        // Update the list of places
        // This will trigger the build method to update the UI with suggestions
        // received from the Google Places API.
        // Ensure that `listForPlaces` is a list of Strings or whatever type you need to display.
        listForPlaces = predictions.map((prediction) => prediction['description'] as String).toList();
      });
    } else {
      throw Exception('Failed to load places');
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
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _getUserLocation();
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
                      // Start searching
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _tcontroller,
                      decoration: InputDecoration(
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
                //color: Colors.white,
                decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(10),
               color: Colors.white,
               border: Border(
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
                        // Handle selection of place from suggestions
                        
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
