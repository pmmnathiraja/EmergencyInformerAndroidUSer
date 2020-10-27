import 'dart:collection';

import 'package:flutter/material.dart';
//import 'package:user/map/map_load_bluetooth.dart';
import 'package:user/_routing/routes.dart';
import 'package:user/screens/feed.dart';
//import 'package:user/serialBluetooth/MainPage.dart';
import 'package:user/views/home.dart';
import 'package:user/views/landing.dart';
//import 'package:user/views/login.dart';
import 'package:user/views/register.dart';
import 'package:user/views/reset_password.dart';
//import 'package:user/map/map_load.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case landingViewRoute:
      return MaterialPageRoute(builder: (context) => LandingPage());
    case homeViewRoute:
      return MaterialPageRoute(builder: (context) => HomePage());
//    case loginViewRoute:
//      return MaterialPageRoute(builder: (context) => LoginPage());
    case registerViewRoute:
      return MaterialPageRoute(builder: (context) => RegisterPage());
    case resetPasswordViewRoute:
      return MaterialPageRoute(builder: (context) => ResetPasswordPage());
//    case mapViewRoute:
//      return MaterialPageRoute(builder: (context) => MapViewMain());
      break;
    default:
      return MaterialPageRoute(builder: (context) => LandingPage());
  }
}
