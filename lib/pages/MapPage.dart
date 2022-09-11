import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:herkes_icin_sanat/widgets/HeaderWidget.dart';

import 'HomePage.dart';

class PostItemList {
  final String id;
  final String description;
  final String imageUrl;
  final String price;
  final String username;
  final double latitude;
  final double longitude;
  final double distance;

  PostItemList(
      {this.id,
      this.description,
      this.imageUrl,
      this.price,
      this.username,
      this.latitude,
      this.longitude,
      this.distance});
}

class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> nearestFiveMarker = {};
  final List<PostItemList> itemList = [];
  Position currentPosition;
  var geoLocator = Geolocator();

  _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPosition = position;
    });

    LatLng latlngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latlngPosition, zoom: 10);
    final GoogleMapController myController = await _controller.future;
    myController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    await allPostReferences.get().then((dataSnapshot) {
      dataSnapshot.docs.forEach((doc) {
        double distanceInMeter = Geolocator.distanceBetween(position.latitude,
                position.longitude, doc.get("latitude"), doc.get("longitude")) /
            1000;
        Marker resultMarker = Marker(
          markerId: MarkerId(doc.get("postId")),
          position: LatLng(doc.get("latitude"), doc.get("longitude")),
          infoWindow: InfoWindow(
            title: doc.get("description"),
            snippet: distanceInMeter.toString(),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        );
        setState(() {
          itemList.add(PostItemList(
              id: doc.get("postId"),
              description: doc.get("description"),
              imageUrl: doc.get("url"),
              latitude: doc.get("latitude"),
              longitude: doc.get("longitude"),
              price: doc.get("price"),
              username: doc.get("username"),
              distance: distanceInMeter));
          nearestFiveMarker.add(resultMarker);
        });
      });
    });
    itemList.sort((a, b) => a.distance.compareTo(b.distance));
  }

  void dispose() {
    super.dispose();
  }

  double zoomVal = 5.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        strTitle: "Harita",
      ),
      body: Stack(
        children: <Widget>[
          _buildGoogleMap(context),
          _buildContainer(),
        ],
      ),
    );
  }

  Future<String> callAsyncFetch() =>
      Future.delayed(Duration(seconds: 2), () => "hi");

  Widget _buildContainer() {
    return FutureBuilder<String>(
        future: callAsyncFetch(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20.0),
                height: 150.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    SizedBox(width: 10.0),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _boxes(
                          itemList[0].imageUrl,
                          itemList[0].latitude.toDouble(),
                          itemList[0].longitude.toDouble(),
                          itemList[0].description,
                          itemList[0].username,
                          itemList[0].distance,
                          itemList[0].price),
                    ),
                    SizedBox(width: 10.0),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _boxes(
                          itemList[1].imageUrl,
                          itemList[1].latitude.toDouble(),
                          itemList[1].longitude.toDouble(),
                          itemList[1].description,
                          itemList[1].username,
                          itemList[1].distance,
                          itemList[1].price),
                    ),
                    SizedBox(width: 10.0),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _boxes(
                          itemList[2].imageUrl,
                          itemList[2].latitude.toDouble(),
                          itemList[2].longitude.toDouble(),
                          itemList[2].description,
                          itemList[2].username,
                          itemList[2].distance,
                          itemList[2].price),
                    ),
                    SizedBox(width: 10.0),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _boxes(
                          itemList[3].imageUrl,
                          itemList[3].latitude.toDouble(),
                          itemList[3].longitude.toDouble(),
                          itemList[3].description,
                          itemList[3].username,
                          itemList[3].distance,
                          itemList[3].price),
                    ),
                    SizedBox(width: 10.0),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _boxes(
                          itemList[4].imageUrl,
                          itemList[4].latitude.toDouble(),
                          itemList[4].longitude.toDouble(),
                          itemList[4].description,
                          itemList[4].username,
                          itemList[4].distance,
                          itemList[4].price),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  Widget _boxes(String _image, double lat, double long, String description,
      String artist, double distance, String price) {
    return GestureDetector(
      onTap: () {
        _gotoLocation(lat, long);
      },
      child: Container(
        child: new FittedBox(
          child: Material(
              color: Theme.of(context).accentColor,
              elevation: 14.0,
              borderRadius: BorderRadius.circular(24.0),
              shadowColor: const Color(0xFF121212),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 150,
                    height: 150,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(24.0),
                      child: Image(
                        fit: BoxFit.fill,
                        image: NetworkImage(_image),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: myDetailsContainer1(
                          description, artist, distance, price),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget myDetailsContainer1(String postDescription, String postUsername,
      double postDistance, String price) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
              child: Text(
            postDescription,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 24.0,
                fontWeight: FontWeight.bold),
          )),
        ),
        SizedBox(height: 5.0),
        Container(
            child: Text(
          postUsername,
          style: TextStyle(
            color: const Color(0xFFFBFBFB),
            fontSize: 18.0,
          ),
        )),
        SizedBox(height: 5.0),
        Container(
            child: Text(
          price + "tl",
          style: TextStyle(
              color: const Color(0xFFFBFBFB),
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        )),
        SizedBox(height: 10.0),
        Container(
            child: Text(
          postDistance.toStringAsFixed(2) + " km",
          style: TextStyle(
              color: const Color(0xFFFBFBFB),
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        )),
      ],
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition:
            //current position gelecek buraya
            CameraPosition(target: LatLng(0, 0), zoom: 10),
        onMapCreated: _onMapCreated,
        markers: nearestFiveMarker,
        myLocationButtonEnabled: true,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 15,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }
}
