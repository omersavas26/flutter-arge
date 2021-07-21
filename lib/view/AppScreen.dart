import 'package:angaryos/helper/BaseHelper.dart';
import 'package:angaryos/route/RouteGenerator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'MainScreen.dart';

class App extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  preLoad(BuildContext context) async {
    BaseHelper.context = context;
  }

  @override
  void initState() {
    super.initState();
    BaseHelper.setActiveContext(context);
    if (!kIsWeb) BaseHelper.firebaseDynamicLinkControl();
  }

  @override
  Widget build(BuildContext context) {
    this.preLoad(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: MainScreen(),

      initialRoute: "/" + BaseHelper.defaultLanguage + "/",
      //routes: {'/second': (_) => SecondPage(data: "route ile")},
      onGenerateRoute: RouteGenerator.generatoeRoute,
    );
  }
}
