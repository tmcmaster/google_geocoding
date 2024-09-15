import 'package:google_geocoding/src/models/northeast.dart';
import 'package:google_geocoding/src/models/southwest.dart';

class Viewport {
  final Northeast? northeast;
  final Southwest? southwest;

  Viewport({
    this.northeast,
    this.southwest,
  });

  factory Viewport.fromJson(Map<String, dynamic> json) {
    return Viewport(
      northeast: json['northeast'] != null
          ? Northeast.fromJson(json['northeast'] as Map<String, dynamic>)
          : null,
      southwest: json['southwest'] != null
          ? Southwest.fromJson(json['southwest'] as Map<String, dynamic>)
          : null,
    );
  }
}
