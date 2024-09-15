import 'package:google_geocoding/src/models/northeast.dart';
import 'package:google_geocoding/src/models/southwest.dart';

class Bounds {
  final Northeast? northeast;
  final Southwest? southwest;

  Bounds({
    this.northeast,
    this.southwest,
  });

  factory Bounds.fromJson(Map<String, dynamic> json) {
    return Bounds(
      northeast: json['northeast'] != null
          ? Northeast.fromJson(json['northeast'] as Map<String, dynamic>)
          : null,
      southwest: json['southwest'] != null
          ? Southwest.fromJson(json['southwest'] as Map<String, dynamic>)
          : null,
    );
  }
}
