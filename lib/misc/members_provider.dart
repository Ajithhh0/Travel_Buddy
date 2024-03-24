import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemberRefsProvider with ChangeNotifier {
 List<DocumentReference> _memberRefs = [];

 List<DocumentReference> get memberRefs => _memberRefs;

 void updateMemberRefs(List<DocumentReference> newRefs) {
    _memberRefs = newRefs;
    notifyListeners(); // Notify listeners to rebuild UI with new data
 }
}
