import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewBudget extends StatefulWidget {
  final String tripName;

  const ViewBudget({Key? key, required this.tripName}) : super(key: key);

  @override
  State<ViewBudget> createState() => _ViewBudgetState();
}

class _ViewBudgetState extends State<ViewBudget> {
  double budget = 0.0;
  double totalExpenses = 0.0;
  List<Map<String, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    fetchBudgetDetails();
  }

  Future<void> fetchBudgetDetails() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      final tripDetailsDocumentRef =
          userDocRef.collection('trips').doc(widget.tripName);

      final budgetDocumentSnapshot =
          await tripDetailsDocumentRef.collection('budget').doc('details').get();

      if (budgetDocumentSnapshot.exists) {
        final budgetData = budgetDocumentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          budget = budgetData['budget'];
          expenses = List<Map<String, dynamic>>.from(budgetData['expenses']);
          totalExpenses = budgetData['total_expenses'];
        });
      }
    }
  }
  void addExpense(String description, double amount) {
    setState(() {
      expenses.add({'description': description, 'amount': amount});
      totalExpenses += amount;
    });
  }

  void updateExpense(String description, double amount, int index) {
    setState(() {
      expenses[index] = {'description': description, 'amount': amount};
      totalExpenses = expenses.fold(0, (prev, curr) => prev + curr['amount']);
    });
  }

  void removeExpense(int index) {
    setState(() {
      totalExpenses -= expenses[index]['amount'];
      expenses.removeAt(index);
    });
  }

  Future<void> saveChanges() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      final tripDetailsDocumentRef =
          userDocRef.collection('trips').doc(widget.tripName);

      final budgetCollectionRef = tripDetailsDocumentRef.collection('budget');

      await budgetCollectionRef.doc('details').set({
        'budget': budget,
        'expenses': expenses,
        'total_expenses': totalExpenses,
        'remaining_budget': budget - totalExpenses,
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
                                  await saveChanges();
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
            rows: expenses.asMap().entries.map((entry) {
              final index = entry.key;
              final expense = entry.value;
              return DataRow(
                cells: [
                  DataCell(Text(expense['description'])),
                  DataCell(Text('${expense['amount']}')),
                ],
                
                onSelectChanged: (isSelected) {
                  if (isSelected != null && isSelected) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String description = expense['description'];
                        double amount = expense['amount'];

                        return AlertDialog(
                          title: const Text('Edit Expense'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                initialValue: description,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                ),
                                onChanged: (value) {
                                  description = value;
                                },
                              ),
                              TextFormField(
                                initialValue: amount.toString(),
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
                                updateExpense(description, amount, index);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Save'),
                            ),
                            TextButton(
                              onPressed: () {
                                removeExpense(index);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
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
                '${(budget - totalExpenses).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
