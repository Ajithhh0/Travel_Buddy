import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:travel_buddy/misc/weather_consts.dart';

class WeatherForecast extends StatefulWidget {
  @override
  _WeatherForecastState createState() => _WeatherForecastState();
}

class _WeatherForecastState extends State<WeatherForecast> {
  String _currentWeather = '';

  @override
  void initState() {
    super.initState();
    _getCurrentWeather();
  }

  Future<void> _getCurrentWeather() async {
    try {
      // Get the current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // API endpoint and API key
      String apiEndpoint =
          'http://api.openweathermap.org/data/2.5/forecast?id=524901&appid=${weatherapi}';

      // Make the API request
      http.Response response = await http.get(Uri.parse(apiEndpoint));

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> weatherData = jsonDecode(response.body);

        // Extract the current weather description
        String weatherDescription =
            weatherData['weather'][0]['description'].toString();

        setState(() {
          _currentWeather = weatherDescription;
        });
      } else {
        print('Failed to fetch weather data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Weather',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              _currentWeather,
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}