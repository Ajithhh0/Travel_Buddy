import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_buddy/screens/plan_a_journey/models/trip_model.dart';
import 'display_details.dart';

class BudgetPlanner extends StatefulWidget {
  final String? tripName;
  final List<Member> savedMembers;
  final String? startingLocation;
  final String? destinationLocation;
  const BudgetPlanner({
    Key? key,
    required this.tripName,
    required this.savedMembers,
    required this.startingLocation,
    required this.destinationLocation,
  }) : super(key: key);

  @override
  State<BudgetPlanner> createState() => _BudgetPlannerState();
}

class _BudgetPlannerState extends State<BudgetPlanner> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double budget = 0.0;
  double totalExpenses = 0.0;
  final List<Map<String, dynamic>> expenses = [];

  void addExpense(String description, double amount) {
    setState(() {
      expenses.add({'description': description, 'amount': amount});
      totalExpenses += amount;
    });
  }

  double get remainingBudget => budget - totalExpenses;

  Future<void> saveToDatabase() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    final tripsCollectionRef = userDocRef.collection('trips');
    final tripDocRef = tripsCollectionRef.doc(widget.tripName);

    // Reference to the budget_details collection inside the trip
    final budgetDetailsCollectionRef = tripDocRef.collection('budget_details');

    // Save budget details directly as documents inside the budget_details collection
    await budgetDetailsCollectionRef.doc('details').set({
      'budget': budget,
      'expenses': expenses,
      'remaining_budget': remainingBudget,
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Budget'),
         shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        backgroundColor: const Color.fromARGB(255, 151, 196, 232),
      ),
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Set Budget'),
                            content: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'Enter Budget'),
                              onChanged: (value) {
                                setState(() {
                                  budget = double.tryParse(value) ?? 0.0;
                                });
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await saveToDatabase();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Set Budget'),
                  ),
                  const SizedBox(width: 5),
                  Text(' ${budget.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      String description = '';
                      double amount = 0.0;

                      return AlertDialog(
                        title: const Text('Add Expense'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Description',
                              ),
                              onChanged: (value) {
                                description = value;
                              },
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                              ),
                              onChanged: (value) {
                                amount = double.tryParse(value) ?? 0.0;
                              },
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              addExpense(description, amount);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(width: 10),
              const Text(
                'Expenses',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DataTable(
            columns: const [
              DataColumn(label: Text('Description')),
              DataColumn(label: Text('Amount')),
            ],
            rows: expenses.map((expense) {
              return DataRow(
                cells: [
                  DataCell(Text(expense['description'])),
                  DataCell(Text('${expense['amount']}')),
                ],
              );
            }).toList()
              ..add(
                DataRow(cells: [
                  const DataCell(Text('Total expenses')),
                  DataCell(Text('$totalExpenses')),
                ]),
              ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Remaining Budget:'),
              Text(
                '${remainingBudget.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await saveToDatabase();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmDetails(
                tripName: widget.tripName,
                savedMembers: widget.savedMembers,
                startingLocation: widget.startingLocation ?? 'Default Starting Location',
                destinationLocation: widget.destinationLocation ?? 'Default Destination Location',
              ),
            ),
          );
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
