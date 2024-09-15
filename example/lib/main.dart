import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_geocoding/google_geocoding.dart';
import 'package:google_place/google_place.dart' as gp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // late GoogleGeocoding googleGeocoding;
  final addressController = TextEditingController();
  double latitude = 0;
  double longitude = 0;
  GeocodingTypes geocodingTypes = GeocodingTypes.geocoding;
  List<GeocodingResult> geocodingResults = [];
  List<GeocodingResult> reverseGeocodingResults = [];
  late final Future<GoogleGeocoding> _googleGeocoding;

  @override
  void initState() {
    final completer = Completer<GoogleGeocoding>();
    _googleGeocoding = completer.future;
    final dotEnv = DotEnv();
    try {
      dotEnv.load(fileName: '.env').then((_) {
        final apiKey = dotEnv.env['API_KEY'];
        if (apiKey == null) {
          completer.completeError('API_KEY has not been set.');
        } else {
          debugPrint('===> Creating GoogleGeocoding: $apiKey');
          completer.complete(GoogleGeocoding(apiKey));
        }
      });
    } catch (error) {
      completer.completeError(error);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          print('===>> geocodingSearch');
          if (geocodingTypes == GeocodingTypes.geocoding) {
            print('===>> geocodingSearch: ${addressController.text}');
            if (addressController.text != '') {
              geocodingSearch(addressController.text);
            } else {
              if (mounted) {
                setState(() {
                  geocodingResults = [];
                });
              }
            }
          }

          if (geocodingTypes == GeocodingTypes.reverseGeocoding) {
            final latLon = LatLon(latitude, longitude);
            reverseGeocodingSearch(latLon);
          }
        },
        label: const Text('Search'),
        icon: const Icon(
          Icons.search,
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(right: 20),
                  child: DropdownButton<GeocodingTypes>(
                    value: geocodingTypes,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blueAccent,
                    ),
                    iconSize: 24,
                    elevation: 16,
                    underline: Container(
                      height: 1,
                      color: Colors.blueAccent,
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          geocodingTypes = value;
                        });
                      }
                    },
                    items: GeocodingTypes.values.map((GeocodingTypes newValue) {
                      return DropdownMenuItem<GeocodingTypes>(
                        value: newValue,
                        child: Text(
                          newValue == GeocodingTypes.geocoding
                              ? 'Geocoding'
                              : newValue == GeocodingTypes.reverseGeocoding
                                  ? 'Reverse Geocoding'
                                  : '',
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            inherit: false,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              if (geocodingTypes == GeocodingTypes.geocoding)
                Container(
                  margin: const EdgeInsets.only(right: 20, left: 20, top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Geocoding',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black54,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(),
              if (geocodingTypes == GeocodingTypes.reverseGeocoding)
                Container(
                  margin: const EdgeInsets.only(right: 20, left: 20, top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Reverse Geocoding',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 30),
                        child: ListTile(
                          title: Text(
                            'Lat: ${latitude.toStringAsFixed(5)}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          subtitle: Slider(
                            min: -90.0,
                            max: 90.0,
                            divisions: 1000000,
                            label: latitude.toStringAsFixed(5),
                            activeColor: Colors.blueAccent,
                            inactiveColor: Colors.blueAccent[100],
                            value: latitude,
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  latitude = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 30),
                        child: ListTile(
                          title: Text(
                            'Lng: ${longitude.toStringAsFixed(5)}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          subtitle: Slider(
                            min: -180.0,
                            max: 179.99999200000003,
                            divisions: 10000000,
                            label: longitude.toStringAsFixed(5),
                            activeColor: Colors.blueAccent,
                            inactiveColor: Colors.blueAccent[100],
                            value: longitude,
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  longitude = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: geocodingTypes == GeocodingTypes.geocoding
                    ? ListView.builder(
                        itemCount: geocodingResults.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(
                                Icons.pin_drop,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(geocodingResults[index].formattedAddress ?? ''),
                            onTap: () {
                              debugPrint(geocodingResults[index].placeId);
                              if (geocodingResults[index].placeId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsPage(
                                      placeId: geocodingResults[index].placeId!,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: reverseGeocodingResults.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(
                                Icons.pin_drop,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(reverseGeocodingResults[index].formattedAddress ?? ''),
                            onTap: () {
                              debugPrint(reverseGeocodingResults[index].placeId);
                              if (reverseGeocodingResults[index].placeId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsPage(
                                      placeId: reverseGeocodingResults[index].placeId!,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                child: Image.asset('assets/powered_by_google.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> geocodingSearch(String value) async {
    print('===>> geocodingSearch: value : $value');
    final response = await (await _googleGeocoding).geocoding.get(value, []);
    print('===>> geocodingSearch: response : $response');
    if (response != null && response.results != null) {
      if (mounted) {
        setState(() {
          geocodingResults = response.results!;
        });
      } else {
        print('===>> geocodingSearch: not mounted');
      }
    } else {
      if (mounted) {
        setState(() {
          geocodingResults = [];
        });
      } else {
        print('===>> geocodingSearch: not mounted');
      }
    }
  }

  Future<void> reverseGeocodingSearch(LatLon latlng) async {
    final response = await (await _googleGeocoding).geocoding.getReverse(latlng);
    if (response != null && response.results != null) {
      if (mounted) {
        setState(() {
          reverseGeocodingResults = response.results!;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          reverseGeocodingResults = [];
        });
      }
    }
  }
}

class DetailsPage extends StatefulWidget {
  final String placeId;

  const DetailsPage({super.key, required this.placeId});

  @override
  _DetailsPageState createState() => _DetailsPageState(this.placeId);
}

class _DetailsPageState extends State<DetailsPage> {
  final String placeId;
  late final Future<gp.GooglePlace> _gPlace;
  gp.DetailsResult? detailsResult;
  List<Uint8List> images = [];

  _DetailsPageState(this.placeId);

  @override
  void initState() {
    final completer = Completer<gp.GooglePlace>();
    _gPlace = completer.future;
    final dotEnv = DotEnv();
    try {
      dotEnv.load(fileName: '.env').then((_) {
        final apiKey = dotEnv.env['API_KEY'];
        if (apiKey == null) {
          completer.completeError('API_KEY has not been set.');
        } else {
          debugPrint('===> Creating GooglePlace:  $apiKey');
          completer.complete(gp.GooglePlace(apiKey));
          getDetails(placeId);
        }
      });
    } catch (error) {
      completer.completeError(error);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          getDetails(placeId);
        },
        child: const Icon(Icons.refresh),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(right: 20, left: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 250,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.memory(
                            images[index],
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListView(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(left: 15, top: 10),
                        child: const Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (detailsResult != null && detailsResult!.types != null)
                        Container(
                          margin: const EdgeInsets.only(left: 15, top: 10),
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: detailsResult!.types!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 10),
                                child: Chip(
                                  label: Text(
                                    detailsResult!.types![index],
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.blueAccent,
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Container(),
                      Container(
                        margin: const EdgeInsets.only(left: 15, top: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.location_on),
                          ),
                          title: Text(
                            detailsResult != null && detailsResult!.formattedAddress != null
                                ? 'Address: ${detailsResult!.formattedAddress}'
                                : 'Address: null',
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 15, top: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.location_searching),
                          ),
                          title: Text(
                            detailsResult != null &&
                                    detailsResult!.geometry != null &&
                                    detailsResult!.geometry!.location != null
                                ? 'Geometry: ${detailsResult!.geometry!.location!.lat},${detailsResult!.geometry!.location!.lng}'
                                : 'Geometry: null',
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 15, top: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.timelapse),
                          ),
                          title: Text(
                            detailsResult != null && detailsResult!.utcOffset != null
                                ? 'UTC offset: ${detailsResult!.utcOffset} min'
                                : 'UTC offset: null',
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 15, top: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.rate_review),
                          ),
                          title: Text(
                            detailsResult != null && detailsResult!.rating != null
                                ? 'Rating: ${detailsResult!.rating.toString()}'
                                : 'Rating: null',
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 15, top: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.attach_money),
                          ),
                          title: Text(
                            detailsResult != null && detailsResult!.priceLevel != null
                                ? 'Price level: ${detailsResult!.priceLevel}'
                                : 'Price level: null',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 10),
                child: Image.asset('assets/powered_by_google.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getDetails(String placeId) async {
    debugPrint('Getting details: $placeId');
    try {
      final result = await (await _gPlace).details.get(placeId);
      if (result != null && result.result != null && mounted) {
        debugPrint('Result: $placeId : $result');
        setState(() {
          detailsResult = result.result;
          images = [];
        });

        if (result.result!.photos != null) {
          debugPrint('Photos: $placeId : ${result.result!.photos}');
          for (final photo in result.result!.photos!) {
            if (photo.photoReference != null) {
              getPhoto(photo.photoReference!);
            }
          }
        }
      } else {
        debugPrint('No result: $placeId');
      }
    } catch (error) {
      debugPrint('getDetails : $error');
    }
  }

  Future<void> getPhoto(String photoReference) async {
    final result = await (await _gPlace).photos.get(photoReference, 400, 400);
    if (result != null && mounted) {
      setState(() {
        images.add(result);
      });
    }
  }
}

enum GeocodingTypes {
  geocoding,
  reverseGeocoding,
}
