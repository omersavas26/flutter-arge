import 'package:angaryos/helper/BaseHelper.dart';
import 'package:flutter/material.dart';
import 'AppScreen.dart';

class SplashScreenController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: BaseHelper.fireBaseAppAsync,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(home: Splash());
        } else {
          return App();
        }
      },
    );
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Icon(
          Icons.local_drink,
          size: MediaQuery.of(context).size.width * 0.785,
        ),
      ),
    );
  }
}
