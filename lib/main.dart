// @dart=2.9
import 'dart:async';
import 'dart:io';

import 'package:angaryos/view/SplashScreen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:angaryos/helper/SessionHelper.dart';

import 'package:angaryos/helper/BaseHelper.dart';

void generalOperations() async {
  HttpOverrides.global = new AngaryosHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
}

Future<void> preLoad() async {
  generalOperations();
}

void main() async {
  preLoad();
  await BaseHelper.firebaseOperations();

  if (kIsWeb) {
    runApp(SplashScreenController());
  } else {
    runZonedGuarded(() {
      runApp(SplashScreenController());
    }, FirebaseCrashlytics.instance.recordError);
  }
}
