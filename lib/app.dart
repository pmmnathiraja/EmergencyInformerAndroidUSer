import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:user/_routing/routes.dart';
import 'package:user/_routing/router.dart' as router;
import 'package:user/theme.dart';
import 'package:location_permissions/location_permissions.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<PermissionStatus> permission = LocationPermissions().requestPermissions();
    return MaterialApp(

      title: 'Emergency Informer',
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(),
      onGenerateRoute: router.generateRoute,
      initialRoute: landingViewRoute,
    );
  }
}
