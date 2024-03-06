import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy/misc/app_info.dart';
import 'package:travel_buddy/screens/plan_a_journey/models/trip_model.dart';

class ConfirmDetails extends StatefulWidget {
  final String? tripName;
  final List<Member> savedMembers;

  const ConfirmDetails({
    Key? key,
    this.tripName,
    required this.savedMembers, required String startingLocation, required String destinationLocation,
  }) : super(key: key);

  @override
  _ConfirmDetailsState createState() => _ConfirmDetailsState();
}

class _ConfirmDetailsState extends State<ConfirmDetails> {
  late String startLocation;
  late String destinationLocation;

  @override
  void initState() {
    super.initState();
    // Retrieve start and destination locations from the provider
    startLocation = Provider.of<AppInfo>(context, listen: false)
        .startLocation
        ?.humanReadableAddress ?? 'Not Available';
    destinationLocation = Provider.of<AppInfo>(context, listen: false)
        .destinationLocation
        ?.humanReadableAddress ?? 'Not Available';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Name: ${widget.tripName ?? ''}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Starting Location: $startLocation'),
            const SizedBox(height: 10),
            Text('Destination Location: $destinationLocation'),
            const SizedBox(height: 20),
            const Text(
              'Members:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.savedMembers.length,
              itemBuilder: (context, index) {
                final member = widget.savedMembers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(member.avatarUrl),
                  ),
                  title: Text(member.name),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
