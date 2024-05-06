import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_buddy/misc/shimmer_widget.dart';

class RolesScreen extends StatefulWidget {
  final String tripId;

  const RolesScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  _RolesScreenState createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  DocumentSnapshot? tripSnapshot;
  late DocumentReference creatorRef;
  late String currentUserUid;
  List<Map<String, dynamic>> roleAssignments = [];
  List<String> roleNames = [];

  final TextEditingController _roleController = TextEditingController();
  late Map<String, String?> selectedRoles =
      {}; // Map to store selected roles for each member or creator

  late Stream<QuerySnapshot> rolesStream; // Define rolesStream variable

  @override
  void initState() {
    super.initState();
    // Initialize selected roles map with default values
    FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .get()
        .then((documentSnapshot) {
      if (documentSnapshot.exists) {
        List<dynamic>? members = documentSnapshot.data()?['members'];
        if (members != null) {
          for (var memberData in members) {
            String memberUid = memberData['memberUid'];
            selectedRoles[memberUid] = null;
          }
        }
        creatorRef = documentSnapshot['created_by'] as DocumentReference;
      }
    });

    rolesStream = FirebaseFirestore.instance
        .collection('roles')
        .where('tripId', isEqualTo: widget.tripId)
        .snapshots();

    roleNames = [];
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          currentUserUid = user.uid;
        });
      }
    });

    _fetchTripData();
  }

  Future<void> _fetchTripData() async {
    try {
      FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .snapshots()
          .listen((DocumentSnapshot snapshot) {
        setState(() {
          tripSnapshot = snapshot;
         // creatorRef = tripSnapshot?['created_by'][0]['creatorUid'] as DocumentReference;
        });
      });
    } catch (e) {
      print('Error fetching trip data: $e');
    }
  }

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  Widget _buildRoleDropdown(String memberUid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('roles')
          .doc(widget.tripId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData) {
          return Text('No roles found');
        }

        final rolesData = snapshot.data!.data() as Map<String, dynamic>?;
        final List<dynamic> roleNames = rolesData?['roleNames'] ?? [];

        return DropdownButton<String>(
          value: selectedRoles[memberUid],
          items: roleNames.map<DropdownMenuItem<String>>((roleName) {
            return DropdownMenuItem<String>(
              value: roleName,
              child: Text(roleName),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              selectedRoles[memberUid] = value;
            });
            print('Selected Role for $memberUid: $value');
          },
        );
      },
    );
  }

  Widget _buildMemberTile(String memberUid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(memberUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _memberShimmer();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Text('No data found');
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final String userName = userData['username'] as String;
        final String avatarUrl = userData['avatar_url'] as String;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
          ),
          title: Text(userName),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRoleDropdown(
                  memberUid), // Pass member UID to identify each dropdown
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tripSnapshot == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(tripSnapshot?['created_by'][0]['creatorUid'])
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> creatorSnapshot) {
                if (creatorSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return _memberShimmer();
                } else if (creatorSnapshot.hasError) {
                  return const Text('Error fetching creator data');
                } else {
                  Map<String, dynamic> creatorData =
                      creatorSnapshot.data!.data() as Map<String, dynamic>;
                  String creatorUsername =
                      creatorData['username'] ?? 'Unknown User';
                  String creatorAvatarUrl = creatorData['avatar_url'] ?? '';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(creatorAvatarUrl),
                    ),
                    title: Text(creatorUsername),
                    subtitle: const Text('Trip Admin'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildRoleDropdown(tripSnapshot!['created_by'][0]['creatorUid']), // Pass creator UID
                      ],
                    ),
                  );
                }
        
              },
              ),
          Expanded(
            child: ListView.builder(
              itemCount: tripSnapshot?['members'].length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> memberData =
                    tripSnapshot?['members'][index] as Map<String, dynamic>;
                final String memberUid = memberData['memberUid'] as String;
                final int acceptanceStatus =
                    memberData['acceptance_status'] as int;

                if (currentUserUid == tripSnapshot!['created_by'][0]['creatorUid']||
                    (currentUserUid == memberUid && acceptanceStatus == 2)) {
                  return _buildMemberTile(memberUid);
                }

                return Container(); // Return an empty container for non-admin and non-accepted members
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: confirmDetails,
                child: const Text('Confirm'),
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      String newRole = '';
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return AlertDialog(
                            title: Text("Add Role"),
                            content: TextField(
                              onChanged: (value) {
                                setState(() {
                                  newRole = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Enter role",
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: newRole.isNotEmpty
                                    ? () {
                                        _addRole(newRole);
                                        Navigator.pop(context);
                                      }
                                    : null,
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
                child: const Text('Add Roles'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addRole(String role) {
    CollectionReference rolesCollection =
        FirebaseFirestore.instance.collection('roles');

    rolesCollection
        .doc(widget.tripId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        List<dynamic> existingRoles =
            (documentSnapshot.data() as Map<String, dynamic>)['roleNames'] ??
                [];
        existingRoles.add(role);
        rolesCollection.doc(widget.tripId).update({
          'roleNames': existingRoles,
        }).then((_) {
          print('Role added successfully');
        }).catchError((error) {
          print("Failed to add role: $error");
        });
      } else {
        rolesCollection.doc(widget.tripId).set({
          'tripId': widget.tripId,
          'roleNames': [role],
          'created_by': currentUserUid,
        }).then((_) {
          print('Role added successfully');
        }).catchError((error) {
          print("Failed to add role: $error");
        });
      }
    }).catchError((error) {
      print("Failed to check if document exists: $error");
    });
  }

  void confirmDetails() async {
  try {
    // Get the trip document reference
    final tripDocRef =
        FirebaseFirestore.instance.collection('trips').doc(widget.tripId);

    // Fetch the current trip document data
    final tripDoc = await tripDocRef.get();
    final tripData = tripDoc.data() as Map<String, dynamic>?;

    // Create a list of updated member data with roles
    final updatedMembers = <Map<String, dynamic>>[];

    // Iterate over the existing members
    for (final memberData in tripData?['members'] as List<dynamic>? ?? []) {
      final memberUid = memberData['memberUid'] as String;
      final acceptanceStatus = memberData['acceptance_status'] as int;

      // Add the selected role to the member data
      updatedMembers.add({
        'memberUid': memberUid,
        'acceptance_status': acceptanceStatus,
        'role': selectedRoles[memberUid],
      });
    }

    // Update the members field in the trip document
    await tripDocRef.update({'members': updatedMembers});

    // Update the creator data if the current user is the creator
    if (currentUserUid == tripData?['created_by'][0]['creatorUid']) {
      // Update the creator data with the selected role
      final updatedCreatorData = {
        'creatorUid': currentUserUid,
        'acceptance_status': 2,
        'role': selectedRoles[currentUserUid],
      };

      // Update the creator data in the trip document
      await tripDocRef.update({
        'created_by': [updatedCreatorData],
      });
    }

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Roles updated successfully')),
    );
  } catch (e) {
    print('Error updating roles: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to update roles')),
    );
  }
}

  Widget _memberShimmer() => ListTile(
        leading: ShimmerWidget.circular(height: 64, width: 64),
        title: Align(
          alignment: Alignment.centerLeft,
          child: ShimmerWidget.rectangular(
              width: MediaQuery.of(context).size.width * 0.3, height: 16),
        ),
        subtitle: ShimmerWidget.rectangular(height: 10),
      );
}
