import 'package:google_geocoding/src/geocoding/geocoding.dart';

/// The Geocoding API is a service that provides geocoding and reverse geocoding of addresses.
class GoogleGeocoding {
  /// [apiKEY] Your application's API key. This key identifies your application.
  final String apiKEY;
  late Geocoding geocoding;

  GoogleGeocoding(this.apiKEY) {
    geocoding = Geocoding(apiKEY);
  }
}
