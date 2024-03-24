import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemberRefsProvider with ChangeNotifier {
 List<DocumentReference> _memberRefs = [];

 List<DocumentReference> get memberRefs => _memberRefs;

 void updateMemberRefs(List<DocumentReference> newRefs) {
    Future.delayed(Duration.zero, () {
      _memberRefs = newRefs;
      notifyListeners();
      print('Updated memberRefs: $_memberRefs');
    });
 }
}
