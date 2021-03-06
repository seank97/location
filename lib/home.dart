import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './login.dart';
import './friendlist.dart';
import './events.dart';
import './styles.dart' as styles;
import './test.dart';
import 'services/location_service.dart';
import './models/location.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  final Set<Marker> _markers = {};

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  void _getLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _markers.clear();
      final marker = Marker(
        markerId: MarkerId("start"),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(title: 'Your Location'),
      );
      final destMarker = Marker(
        markerId: MarkerId('dest'),
        position: LatLng(35, -120),
        infoWindow: InfoWindow(title: 'Destination'),
      );
      _markers.add(marker);
      _markers.add(destMarker);
    });
  }

  var userName = '';

  void getName() {
    Firestore.instance
        .collection('users')
        .document(LoginState.userEmail)
        .get()
        .then((value) => setState(() {
              userName = value.data['name'];
            }));
  }

  var locationService = LocationService.getInstance();

  @override
  Widget build(BuildContext context) {
    getName();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '@location',
          style: TextStyle(fontFamily: 'Comfortaa'),
        ),
        backgroundColor: styles.atOrange,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.update),
            onPressed: () {
              locationService.updateLocation(Location(100, 100));
            },
          ),
          IconButton(
            icon: Icon(Icons.access_alarm),
            onPressed: () {
              locationService.getCurrentLocation();
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: GoogleMap(
        mapType: MapType.normal,
        compassEnabled: true,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        initialCameraPosition: _kGooglePlex,
        markers: _markers != null ? Set<Marker>.from(_markers) : null,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
//      floatingActionButton: Column(
//        mainAxisAlignment: MainAxisAlignment.end,
//        children: <Widget>[
//          FloatingActionButton.extended(
//            heroTag: 'a',
//            onPressed: _goToTheLake,
//            label: Text('Center'),
//            //icon: Icon(Icons.directions_boat),
//          ),
//          SizedBox(
//            height: 10,
//          ),
//          FloatingActionButton.extended(
//            heroTag: 'b',
//            onPressed: _getLocation,
//            label: Text('Pin'),
//          ),
//        ],
//      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 90,
              child: DrawerHeader(
                child: Text(
                  userName,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                decoration: BoxDecoration(
                  color: styles.atOrange,
                ),
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Events'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Events(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Friends'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FriendList(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () async {
                await _auth.signOut();
                print('Logout successful');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Test'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Test(),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
