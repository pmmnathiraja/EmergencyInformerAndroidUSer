import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user/api/food_api.dart';
import 'package:user/map/map_load_bluetooth.dart';
import 'package:user/model/user.dart';
import 'package:user/notifier/auth_notifier.dart';
import 'package:user/screens/feed.dart';
import 'package:provider/provider.dart';
import 'package:user/views/landing.dart';

class MapViewMain extends StatefulWidget {
  @override
  _MapViewMainState createState() => _MapViewMainState();
}

class _MapViewMainState extends State<MapViewMain> {
  User _firebaseUser = FirebaseAuth.instance.currentUser;
  GoogleMapController mapController;
  double _originLatitude, _originLongitude;
  double _destLatitude, _destLongitude;
  double _initLatitude = 0, _initLongitude = 0;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polyLines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = 'AIzaSyA8GY4o9vAR6URMqU6c4AE1UGLkfDG8iik';
  AuthNotifier authNotifier;
  UserData userPersonalData = UserData();
  int informEmergency = 0;
  int resetData = 0;
  int resetTextCondition = 0;
  String _textString = "Inform Emergency";
  Position currentLocation;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('Users')
        .doc(_firebaseUser.displayName)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print(documentSnapshot.data()['Name']);
        userPersonalData.displayUserName = documentSnapshot.data()['Name'];
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  void deleteRequest() {
    FirebaseFirestore.instance
        .collection("RequestPool")
        .doc(_firebaseUser.displayName)
        .delete();
    informEmergency = 0;
    setState(() {
      _textString = "Inform Emergency";
    });
  }

  void uploadRequest() {
    FirebaseFirestore.instance
        .collection("RequestPool")
        .doc(_firebaseUser.displayName)
        .set({
      'User_Location': GeoPoint(_originLatitude, _originLongitude)
    }).then((_) {
      print("success!");
    });
    informEmergency = 1;
    setState(() {
      _textString = "Cancel The Request";
    });
  }

  void resetAfterComplete() {
    polylineCoordinates.clear();
    markers.clear();
    polyLines.clear();
    resetData = 0;
    resetTextCondition = 0;
  }

  @override
  Widget build(BuildContext context) {
    authNotifier = Provider.of<AuthNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('              Your Location'),
          backgroundColor: Colors.indigo,
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('RequestAccepted')
                .doc(_firebaseUser.displayName)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Container();
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              if (snapshot.data.data() != null) {
                informEmergency = 0;
                _textString = "Inform Emergency";
                GeoPoint position = snapshot.data.data()['Driver_Location'];
                _destLatitude = position.latitude;
                _destLongitude = position.longitude;

                return Scaffold(
                  body: Stack(
                    children: <Widget>[
                      FutureBuilder(
                          future: Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.best),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshotData) {
                            if (!snapshotData.hasData) {
                              return Container();
                            } else {
                              resetData = 1;
                              currentLocation = snapshotData.data;
                              _originLatitude = currentLocation.latitude;
                              _originLongitude = currentLocation.longitude;
                              if (_initLatitude != _destLatitude ||
                                  _initLongitude != _destLongitude) {
                                _initLatitude = _destLatitude;
                                _initLongitude = _destLongitude;
                                _initiateLine();
                              }
                              return GoogleMap(
                                //onMapCreated: _onMapCreatedFirst,
                                initialCameraPosition: CameraPosition(
                                  target: const LatLng(
                                      6.93162477957, 79.8421960567),
                                  zoom: 10,
                                ),
                                myLocationEnabled: true,
                                tiltGesturesEnabled: true,
                                compassEnabled: true,
                                scrollGesturesEnabled: true,
                                zoomGesturesEnabled: true,
                                onMapCreated: _onMapCreated,
                                markers: Set<Marker>.of(markers.values),
                                polylines: Set<Polyline>.of(polyLines.values),

                                //markers: _markers.values.toSet(),
                              );
                            }
                          }),
                    ],
                  ),
                );
              } else {
                if (resetData != 0 && snapshot.data.data() == null) {
                  resetAfterComplete();
                }
                return Scaffold(
                  body: Stack(
                    children: <Widget>[
                      FutureBuilder(
                          future: Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.best),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshotData) {
                            if (!snapshotData.hasData) {
                              return Container();
                            } else {
                              currentLocation = snapshotData.data;
                              _originLatitude = currentLocation.latitude;
                              _originLongitude = currentLocation.longitude;
                              return GoogleMap(
                                //onMapCreated: _onMapCreatedFirst,
                                initialCameraPosition: CameraPosition(
                                  target: const LatLng(
                                      6.93162477957, 79.8421960567),
                                  zoom: 10,
                                ),
                                myLocationEnabled: true,
                                tiltGesturesEnabled: true,
                                compassEnabled: true,
                                scrollGesturesEnabled: true,
                                zoomGesturesEnabled: true,
                                onMapCreated: _onMapCreated,
                                markers: Set<Marker>.of(markers.values),
                                polylines: Set<Polyline>.of(polyLines.values),

                                //markers: _markers.values.toSet(),
                              );
                            }
                          }),
                      Positioned(
                        bottom: 10,
                        left: 100,
                        // ignore: missing_required_param
                        child: FloatingActionButton.extended(
                          onPressed: () => {
                            informEmergency == 0
                                ? uploadRequest()
                                : deleteRequest(),
                          },
                          label: Text(_textString),
                          icon: Icon(Icons.info),
                          backgroundColor: Colors.pink,
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
        drawer: Drawer(
          elevation: 4,
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: new Color(0xFF0062ac),
                ),
                accountName: Text(authNotifier.user.displayName),
                accountEmail: Text(authNotifier.user.email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? new Color(0xFF0062ac)
                          : Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'Medical Reports',
                  textScaleFactor: 1.5,
                ),
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return Feed();
                  }));
                },
              ),
              ListTile(
                title: Text(
                  'Via Bluetooth',
                  textScaleFactor: 1.5,
                ),
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return MapLoadBluetooth(userPersonalData);
                  }));
                },
              ),
              ListTile(
                title: Text(
                  'Sign Out',
                  textScaleFactor: 1.5,
                ),
                onTap: () {
                  setupSignOut(_firebaseUser);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void setupSignOut(User _firebaseUser) {
    signOut(_firebaseUser);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return LandingPage();
    }));
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _initiateLine() {
    markers.clear();
//      _addMarker(LatLng(_originLatitude, _originLongitude), "origin",
//          BitmapDescriptor.defaultMarker);

    _addMarker(
      LatLng(_destLatitude, _destLongitude),
      "destination",
      BitmapDescriptor.defaultMarkerWithHue(10),
    );
    print("draw polyline");
    _getPolyline();
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine() {
    polyLines.clear();
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polyLines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyA8GY4o9vAR6URMqU6c4AE1UGLkfDG8iik",
      PointLatLng(_originLatitude, _originLongitude),
      PointLatLng(_destLatitude, _destLongitude),
    );
    polylineCoordinates.clear();
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }
}
