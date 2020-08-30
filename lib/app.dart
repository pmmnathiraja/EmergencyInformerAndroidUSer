import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:user/_routing/routes.dart';
import 'package:user/_routing/router.dart' as router;
import 'package:user/theme.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Social',
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(),
      onGenerateRoute: router.generateRoute,
      initialRoute: landingViewRoute,
    );
  }
}
