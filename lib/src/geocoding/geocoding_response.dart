import 'dart:convert';

import 'package:google_geocoding/src/geocoding/geocoding_result.dart';

class GeocodingResponse {
  final String? status;
  final List<GeocodingResult>? results;

  GeocodingResponse({this.status, this.results});

  factory GeocodingResponse.fromJson(Map<String, dynamic> json) {
    return GeocodingResponse(
      status: json['status'] as String?, // Assuming status can be null
      results: (json['results'] as List<dynamic>?)
          ?.map<GeocodingResult>((json) => GeocodingResult.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  factory GeocodingResponse.parseGeocodingResponse(String responseBody) {
    final parsed = json.decode(responseBody) as Map<String, dynamic>;
    return GeocodingResponse.fromJson(parsed);
  }
}
