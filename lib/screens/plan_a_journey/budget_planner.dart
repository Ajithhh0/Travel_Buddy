import 'package:flutter/material.dart';
import 'package:travel_buddy/screens/plan_a_journey/models/trip_model.dart';
import 'display_details.dart';

class BudgetPlanner extends StatefulWidget {
  final String? tripName;
  final List<Member> savedMembers;
  final String? startingLocation; // Define startingLocation parameter
  final String? destinationLocation; // Define destinationLocation parameter
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
  double budget = 0.0;
  double totalExpenses = 0.0;
  final List<Map<String, dynamic>> expenses = [];

  void setBudget(double amount) {
    setState(() {
      budget = amount;
    });
  }

  void addExpense(String description, double amount) {
    setState(() {
      expenses.add({'description': description, 'amount': amount});
      totalExpenses += amount;
    });
  }

  double get remainingBudget => budget - totalExpenses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Budget'),
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
                      // Display dialog to set budget
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
                                setBudget(double.tryParse(value) ?? 0.0);
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
                                onPressed: () {
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
        onPressed: () {
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
