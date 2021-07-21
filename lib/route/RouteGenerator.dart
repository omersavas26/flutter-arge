import 'package:angaryos/view/MainScreen.dart';
import 'package:angaryos/view/SecondPage.dart';
import 'package:angaryos/view/FailPage.dart';
import 'package:flutter/material.dart';
import 'package:angaryos/helper/BaseHelper.dart';

class RouteGenerator {
  static Route<dynamic> generatoeRoute(RouteSettings settings) {
    //final args = settings.arguments;

    BaseHelper.currentUrlFull = settings.name ?? "";

    var temp = settings.name!.split("?");

    String url = temp[0];

    String data = "";
    if (temp.length > 1) data = settings.name!.replaceAll(url + "?", "");

    String currentLanguagePath = "/" + BaseHelper.getCurrentLanguage(url) + "/";

    if (url == currentLanguagePath) {
      return MaterialPageRoute(
          builder: (_) => MainScreen(),
          settings: RouteSettings(name: currentLanguagePath));
    } else if (url == currentLanguagePath + "second") {
      return MaterialPageRoute(
          builder: (_) => SecondPage(data: data),
          settings:
              RouteSettings(name: currentLanguagePath + 'second?' + data));
    } else {
      return MaterialPageRoute(
          builder: (_) => FailPage(),
          settings: RouteSettings(name: currentLanguagePath + 'fail'));
    }
  }
}
