

//import 'package:user/map/map_load.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user/map/map_load.dart';
import 'package:user/model/user.dart';
import 'package:user/notifier/food_notifier.dart';
import 'package:user/screens/feed.dart';
import 'package:user/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user/views/reset_password.dart';
import 'package:firebase_core/firebase_core.dart';
import 'notifier/auth_notifier.dart';


class LoginInit extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthNotifier(),
        ),
        ChangeNotifierProvider(
          create: (context) => FoodNotifier(),
        ),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Coding with Curry',
         theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.lightBlue,
       ),
             home: Consumer<AuthNotifier>(
                builder: (context, notifier, child) {
                 return notifier.user != null ? MapViewMain() : Login();
          },
        ),
     ),
    );
  }
}


