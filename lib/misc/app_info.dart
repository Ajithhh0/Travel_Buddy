import 'package:flutter/cupertino.dart';
import 'package:travel_buddy/misc/address_model.dart';

class AppInfo extends ChangeNotifier {
  AddressModel? startLocation;
  AddressModel? destinationLocation;

  void updateStartLocation(AddressModel startModel) {
    startLocation = startModel;
    notifyListeners();
  }

  void updateDestinationLocation(AddressModel destinationModel) {
    destinationLocation = destinationModel;
    notifyListeners();
  }
}