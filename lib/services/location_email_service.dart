import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationEmailService {
  Future<void> sendLocationByEmail({
    required String toEmail,
    required String friendUsername,
  }) async {
    final position = await _getCurrentLocation();

    final lat = position.latitude;
    final lng = position.longitude;

    final mapsLink = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    final subject = 'I am free, see my location';
    final body =
        'Hello $friendUsername, I am free, see my location:\n'
        '$mapsLink';

    final emailUri = Uri(
      scheme: 'mailto',
      path: toEmail,
      query: _encodeQueryParameters({
        'subject': subject,
        'body': body,
      }),
    );

    final launched = await launchUrl(emailUri);

    if (!launched) {
      throw Exception('Could not open email app.');
    }
  }

  Future<Position> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is permanently denied.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }
}