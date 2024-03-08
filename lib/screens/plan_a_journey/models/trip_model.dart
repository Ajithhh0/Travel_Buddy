import 'direction_details.dart';

class TripDetails {
  final String? tripName;
  final DirectionDetails? directionDetails;
  final String? startingLocation; // Add startingLocation
  final String? destinationLocation; // Add destinationLocation
  final List<Member> members;
  final Budget budget;
  final List<Expense> expenses;

  TripDetails({
    this.tripName,
    this.directionDetails,
    this.startingLocation,
    this.destinationLocation,
    required this.members,
    required this.budget,
    required this.expenses,
  });
}

class Member {
  final String name;
  final String avatarUrl;
  final String uid;

  Member({
    required this.name,
    required this.avatarUrl,
    required this.uid,
  });
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatar_url': avatarUrl,
     // 'uid': uid,
    };
  }
}

class Budget {
  final double amount;

  Budget({
    required this.amount,
  });
}

class Expense {
  final String description;
  final double amount;

  Expense({
    required this.description,
    required this.amount,
  });
}
