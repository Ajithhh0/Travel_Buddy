import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ItineraryScreen extends StatefulWidget {
  final String tripId;

  const ItineraryScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  _ItineraryScreenState createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final TextEditingController _itemController = TextEditingController();
  CollectionReference itineraryCollection =
      FirebaseFirestore.instance.collection('itinerary');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: itineraryCollection.doc(widget.tripId).collection('items').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading...');
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No itinerary found'),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name']),
                leading: Checkbox(
                  value: data['status'] == 1,
                  onChanged: (bool? value) {
                    updateItemStatus(document.reference, value!);
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Item'),
          content: TextField(
            controller: _itemController,
            decoration: InputDecoration(hintText: 'Enter item name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_itemController.text.isNotEmpty) {
                  _addItem(_itemController.text);
                  Navigator.pop(context);
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _addItem(String itemName) {
    itineraryCollection
        .doc(widget.tripId)
        .collection('items')
        .add({'name': itemName, 'status': 0});
    _itemController.clear();
  }

  void updateItemStatus(DocumentReference itemRef, bool newStatus) {
    itemRef.update({'status': newStatus ? 1 : 0});
  }
}