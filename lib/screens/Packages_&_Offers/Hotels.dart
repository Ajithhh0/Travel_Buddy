import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as htmlDom;

class Hotel {
  final String name;
  final double rate;

  Hotel({required this.name, required this.rate});
}

class HotelOffers extends StatefulWidget {
  @override
  _HotelOffersState createState() => _HotelOffersState();
}

class _HotelOffersState extends State<HotelOffers> {
  List<Hotel> hotels = [];

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch hotel data when the page loads
  }

  Future<void> fetchData() async {
    final url = 'https://www.booking.com';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = htmlParser.parse(response.body);
      final List<Hotel> fetchedHotels = parseHotels(document);
      setState(() {
        hotels = fetchedHotels;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<Hotel> parseHotels(htmlDom.Document document) {
    List<Hotel> parsedHotels = [];
    // Implement parsing logic here
    // Extract hotel names, rates, and other information from the Booking.com HTML document
    return parsedHotels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotel Offers'),
        centerTitle: true,
        
      ),
      body: hotels.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: hotels.length,
              itemBuilder: (context, index) {
                final hotel = hotels[index];
                return ListTile(
                  title: Text(hotel.name),
                  subtitle: Text('Rate: ${hotel.rate.toString()}'),
                );
              },
            ),
    );
  }
}
