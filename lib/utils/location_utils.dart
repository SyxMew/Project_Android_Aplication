import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<void> determinePosition(Function(String) updateAddress) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    updateAddress('Location services are disabled.');
    return;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      updateAddress('Location permissions are denied.');
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    updateAddress('Location permissions are permanently denied.');
    return;
  }

  Position position = await Geolocator.getCurrentPosition();
  getAddressFromLatLng(position, updateAddress);
}

Future<void> getAddressFromLatLng(
    Position position, Function(String) updateAddress) async {
  try {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];

    updateAddress(
        "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}");
  } catch (e) {
    print(e);
  }
}
