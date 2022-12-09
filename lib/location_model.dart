import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:scoped_model/scoped_model.dart';

class LocationModel extends Model {
  LocationData? locationData;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void getLocationData() {
    _isLoading = true;
    notifyListeners();
    provideLocation().then((value) {
      locationData = value;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<LocationData?> provideLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    return _locationData;
  }

  static LocationModel of(BuildContext context) =>
      ScopedModel.of<LocationModel>(context);
}
