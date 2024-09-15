class AddressComponent {
  final String? longName;
  final String? shortName;
  final List<String>? types;

  AddressComponent({
    this.longName,
    this.shortName,
    this.types,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) {
    return AddressComponent(
      longName: json['long_name'] as String?,
      shortName: json['short_name'] as String?,
      types: json['types'] != null ? (json['types'] as List<dynamic>).cast<String>() : null,
    );
  }
}
