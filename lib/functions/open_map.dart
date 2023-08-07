import 'package:url_launcher/url_launcher.dart';

void openGoogleMaps(String address) async {
  String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$address';

  try {
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch Google Maps: $googleMapsUrl';
    }
  } catch (e) {
    print('Error launching Google Maps: $e');
  }
}