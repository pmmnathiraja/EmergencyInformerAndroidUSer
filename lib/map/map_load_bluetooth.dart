import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:user/model/user.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:user/serialBluetooth/MainPage.dart';
import 'package:user/utils/colors.dart';

class LocationService {
  UserLocation _currentLocation;

  var location = Location();
  StreamController<UserLocation> _locationController =
      StreamController<UserLocation>();

  Stream<UserLocation> get locationStream => _locationController.stream;

  LocationService() {
    // Request permission to use location
    location.requestPermission().then((permissionStatus) {
      if (permissionStatus == PermissionStatus.granted) {
        // If granted listen to the onLocationChanged stream and emit over our controller
        location.onLocationChanged.listen((locationData) {
          if (locationData != null) {
            _locationController.add(UserLocation(
              latitude: locationData.latitude,
              longitude: locationData.longitude,
            ));
          }
        });
      }
    });
  }

  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }

    return _currentLocation;
  }
}

class UserLocation {
  final double latitude;
  final double longitude;

  UserLocation({this.latitude, this.longitude});
}

class MapLoadBluetooth extends StatelessWidget {
  MapLoadBluetooth(this.userPersonalData) : super();
  final UserData userPersonalData;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserLocation>(
      create: (context) => LocationService().locationStream,
      child: MaterialApp(
          title: 'GET LOCATION',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Scaffold(
            body: HomeView(userPersonalData),
          )),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView(this.userPersonalData ,{Key key}) : super(key: key);
  final UserData userPersonalData;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: primaryColor),
    );
    var userLocation = Provider.of<UserLocation>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('              Your Location'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Text(
            '               Location \n       latitude  ${userLocation?.latitude}\n  Longitude   ${userLocation?.longitude}'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>{
          userPersonalData.userLatitude = userLocation?.latitude,
          userPersonalData.userLongitude = userLocation?.longitude,
          print(userPersonalData.userLatitude),
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
         return MainPage(userPersonalData);
        })),
        },
        label: Text('Emergency Inform'),
        icon: Icon(Icons.info),
        backgroundColor: Colors.pink,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
