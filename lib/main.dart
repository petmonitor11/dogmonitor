import 'dart:html';
import 'dart:ui' as ui;

import 'package:dogmonitor/location_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_maps/google_maps.dart' as googlemaps;
import 'package:location/location.dart';

import 'locationJs.dart';

void main() {
  // setUrlStrategy(PathUrlStrategy());
  String? latParam = Uri.base.queryParameters["lat"];
  String? longParam = Uri.base.queryParameters["long"];
  runApp(MyApp(lat: latParam, long: longParam));
}

class MyApp extends StatelessWidget {

  String? lat;
  String? long;

  MyApp({this.lat, this.long});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MapStateScreen(lat: lat, long: long),
    );
  }
}

class MapStateScreen extends StatefulWidget {
  String? lat;
  String? long;

  MapStateScreen({super.key, this.lat, this.long});

  @override
  State<MapStateScreen> createState() =>
      _MapScreenModelScreenState(lat: lat, long: long);
}

class _MapScreenModelScreenState extends State<MapStateScreen> {
  String? lat;
  String? long;
  LocationModel locationModel = LocationModel();

  _MapScreenModelScreenState({this.lat, this.long});

  @override
  void initState() {
    super.initState();
    locationModel.getLocationData();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: locationModel,
        child: Scaffold(
          appBar: AppBar(title: const Text("Dog Monitor")),
          body: SafeArea(
            child: ScopedModelDescendant<LocationModel>(
              builder: (context, child, model) {
                if (model.isLoading) {
                  return _buildLoading();
                } else {
                  return getMap(model.locationData, lat, long);
                }
              },
            ),
          ),
        ));
  }
}

Widget getMap(LocationData? locationData, String? latitude, String? longitude) {
  String htmlId = "7";
  // sample param lat=14.7374368&long=120.9671529
  if (latitude != null && longitude != null) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
      final myLatlng = googlemaps.LatLng(double.parse(latitude), double.parse(longitude));

      final mapOptions = googlemaps.MapOptions()
        ..zoom = 16
        ..center = googlemaps.LatLng(double.parse(latitude), double.parse(longitude));

      final elem = DivElement()
        ..id = htmlId
        ..style.width = "100%"
        ..style.height = "100%"
        ..style.border = 'none';

      final map = googlemaps.GMap(elem, mapOptions);

      googlemaps.Marker(googlemaps.MarkerOptions()
        ..position = myLatlng
        ..map = map
        ..title = 'Hello World!');

      return elem;
    });

    return HtmlElementView(viewType: htmlId);
  } else {
    return HtmlElementView(viewType: htmlId);
  }
}

Widget _buildLoading() {
  return const Center(
    child: CircularProgressIndicator(),
  );
}
