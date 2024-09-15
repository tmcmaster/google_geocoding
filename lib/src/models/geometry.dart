import 'package:google_geocoding/src/models/bounds.dart';
import 'package:google_geocoding/src/models/location.dart';
import 'package:google_geocoding/src/models/viewport.dart';

class Geometry {
  final Location? location;
  final String? locationType;
  final Viewport? viewport;
  final Bounds? bounds;

  Geometry({
    this.location,
    this.locationType,
    this.viewport,
    this.bounds,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      location: json['location'] != null
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      locationType: json['location_type'] as String?,
      viewport: json['viewport'] != null
          ? Viewport.fromJson(json['viewport'] as Map<String, dynamic>)
          : null,
      bounds:
          json['bounds'] != null ? Bounds.fromJson(json['bounds'] as Map<String, dynamic>) : null,
    );
  }
}
