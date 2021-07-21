import 'dart:io';

import 'package:angaryos/helper/BaseHelper.dart';
import 'package:angaryos/helper/ResponsiveHelper.dart';
import 'package:angaryos/helper/SessionHelper.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:angaryos/view/SideMenu.dart';
import 'package:angaryos/view/SecondPage.dart';
import 'package:angaryos/helper/LogHelper.dart';
import 'package:sweetalert/sweetalert.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  _HomeScreenState() {
    fillFromLocalStorage();
  }

  String? _path = "";
  Image? _image;
  String _localStorageData = "";
  String _cardId = "";
  String _security = "bekleniyor";
  String _dynamicLink = "boş";

  void _showPhotoLibrary() async {
    var files = await BaseHelper.getFilesFromLibrary(2, "*");
    if (files == null) return;

    if (kIsWeb) {
      setState(() {
        _image = Image.memory(files.first.bytes);
      });
    } else {
      setState(() {
        _path = files.first.path;
      });
    }
  }

  void _showCamera(context) async {
    if (kIsWeb) {
      File? result = await BaseHelper.takePhotoFromCamera(context);
      if (result == null) return;
    } else {
      File? result = await BaseHelper.takePhotoFromCamera(context);
      if (result == null) return;

      setState(() {
        _path = result.path;
      });
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              height: 150,
              child: Column(children: <Widget>[
                ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _showCamera(context);
                    },
                    leading: Icon(Icons.photo_camera),
                    title: Text("Take a picture from camera")),
                ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _showPhotoLibrary();
                    },
                    leading: Icon(Icons.photo_library),
                    title: Text("Choose from photo library"))
              ]));
        });
  }

  void fillFromLocalStorage() async {
    BaseHelper.writeToLocal("omersavas", "içerik data");
    var temp = await BaseHelper.readFromLocal("omersavas");
    setState(() {
      _localStorageData = temp;
    });
  }

  void fillSecurityState() async {
    String temp = "";
    temp += "jail: " + (await BaseHelper.jailBreakControl()).toString();
    " --- ";
    temp += "realDevice: " +
        (await BaseHelper.realDeviceControl()).toString() +
        " --- ";
    temp += "mockLocation: " +
        (await BaseHelper.mockLocationControl()).toString() +
        " --- ";
    temp += "sdCard: " +
        (await BaseHelper.installedExternalStorageControl()).toString() +
        " --- ";
    temp += "general: " +
        (await BaseHelper.generalSecurityControl()).toString() +
        " --- ";

    setState(() {
      _security = temp;
      print(temp);
    });
  }

  @override
  void initState() {
    super.initState();
    BaseHelper.setActiveContext(context);
  }

  @override
  Widget build(BuildContext context) {
    LogHelper.info("deneme info", "test data");
    LogHelper.error("deneme error", "test data");

    return Scaffold(
      key: _scaffoldKey,
      drawer: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 250),
        child: SideMenu(),
      ),
      body: Container(
        color: Colors.yellow,
        child: SafeArea(
          right: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  children: [
                    Text("dyn link: " + _dynamicLink),
                    Text("Yol: " + _path!),
                    if (!kIsWeb)
                      _path == "" ? Text("Şuan yok") : Image.file(File(_path!)),
                    if (kIsWeb) _image == null ? Text("Şuan yok web") : _image!,
                    Row(
                      children: [
                        Text("Kamera"),
                        IconButton(
                          icon: Icon(Icons.camera),
                          onPressed: () {
                            _showOptions(context);
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (ResponsiveHelper.isMobile(context))
                          IconButton(
                            icon: Icon(Icons.menu),
                            onPressed: () {
                              _scaffoldKey.currentState!.openDrawer();
                            },
                          ),
                        trW("Merhaba")
                      ],
                    ),
                    Row(
                      children: [Text(":::" + _localStorageData)],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(child: Text("security: " + _security)),
                        IconButton(
                          icon: Icon(Icons.security_rounded),
                          onPressed: () {
                            fillSecurityState();
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text("link ile"),
                        IconButton(
                          icon: Icon(Icons.open_in_new),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SecondPage(data: "link ile")),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("Url ile"),
                        IconButton(
                          icon: Icon(Icons.open_in_new_off_outlined),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                                "/" +
                                    BaseHelper.currentLanguage +
                                    "/second?key=val22",
                                arguments: "RouteGenerator ve argüman ile");
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("Helper ile"),
                        IconButton(
                          icon: Icon(Icons.open_in_new_off_outlined),
                          onPressed: () {
                            BaseHelper.setActiveContext(context);
                            BaseHelper.navigate("second?key=val226699");
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("http get"),
                        IconButton(
                          icon: Icon(Icons.compare_arrows_outlined),
                          onPressed: () async {
                            String url = BaseHelper.backendBaseUrl;
                            String? json = await SessionHelper.httpGet(url);
                            dynamic obj = await SessionHelper.httpGetJson(url);
                            dynamic objA =
                                await SessionHelper.httpGetJsonA(url);

                            print(json);

                            //error: fail token
                            url =
                                "https://192.168.10.185/api/v1/xqCxdasd78C8XCunCJUd1/tables/users/1/update";
                            dynamic temp =
                                await SessionHelper.httpGetJsonA(url, true);

                            print(temp);
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("http post"),
                        IconButton(
                          icon: Icon(Icons.network_check),
                          onPressed: () async {
                            String url = SessionHelper.getBaseUrlWithToken() +
                                "tables/users/1/update";
                            Map<String, dynamic> data = Map<String, dynamic>();
                            data["name_basic"] = {
                              "type": "string",
                              "data": "Ana223"
                            };
                            data["tc"] = {
                              "type": "string",
                              "data": "17108034240"
                            };
                            data["surname"] = {
                              "type": "string",
                              "data": "Yönetici2"
                            };
                            data["email"] = {
                              "type": "string",
                              "data": "iletisim@omersavas.com"
                            };
                            data["column_set_id"] = {
                              "type": "string",
                              "data": "0"
                            };
                            data["id"] = {"type": "string", "data": "1"};

                            String? json =
                                await SessionHelper.httpPost(url, data);
                            dynamic obj = await SessionHelper.httpPostJson(
                                url, data, true);
                            dynamic obja =
                                await SessionHelper.httpPostJsonA(url, data);

                            print(json);
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("upload photo"),
                        IconButton(
                          icon: Icon(Icons.upload),
                          onPressed: () async {
                            String url = SessionHelper.getBaseUrlWithToken() +
                                "tables/users/1/update";

                            Map<String, dynamic> data = Map<String, dynamic>();
                            data["name_basic"] = {
                              "type": "string",
                              "data": "Ana223"
                            };
                            data["tc"] = {
                              "type": "string",
                              "data": "17108034240"
                            };
                            data["surname"] = {
                              "type": "string",
                              "data": "Yönetici2"
                            };
                            data["email"] = {
                              "type": "string",
                              "data": "iletisim@omersavas.com"
                            };
                            data["column_set_id"] = {
                              "type": "string",
                              "data": "0"
                            };
                            data["id"] = {"type": "string", "data": "1"};

                            var imageFile =
                                await BaseHelper.getFilesFromLibrary(1, "*");

                            if (imageFile != null) {
                              if (kIsWeb) {
                                data["profile_picture[]"] = {
                                  "type": "fileBytes",
                                  "data": [
                                    {
                                      "name": imageFile.first.name,
                                      "bytes": imageFile.first.bytes
                                    }
                                  ]
                                };

                                //print(imageFile.first.name);
                                //print(imageFile.first.bytes.length);
                              } else {
                                data["profile_picture[]"] = {
                                  "type": "filePaths",
                                  "data": [imageFile.first.path]
                                };
                              }
                            }

                            String? html =
                                await SessionHelper.httpPost(url, data);
                            dynamic html2 =
                                await SessionHelper.httpPostJson(url, data);
                            dynamic? html3 =
                                await SessionHelper.httpPostJsonA(url, data);
                            print(html);
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("location"),
                        IconButton(
                          icon: Icon(Icons.gps_fixed),
                          onPressed: () async {
                            try {
                              bool c =
                                  await BaseHelper.locationServiceControl();

                              if (!c) {
                                BaseHelper.toastMessage("konum kapalı!");
                                return;
                              }

                              Position? p = await BaseHelper.getLocation();
                              Position? p1 = await BaseHelper.getLocation();
                              print(p);

                              if (!kIsWeb) {
                                var cb = (source) {
                                  print(source);
                                  var aaaa = 123123;
                                };
                                BaseHelper.trackLocation(cb);
                              }
                              var a = 45234;
                            } catch (e) {
                              print(e);
                              var c = 123;
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("nfc: "),
                        if (_cardId != null) Text(_cardId),
                        IconButton(
                          icon: Icon(Icons.nfc),
                          onPressed: () async {
                            setState(() {
                              _cardId = "okuma bekleniyor...";
                            });

                            var temp = await BaseHelper.getCardId();
                            if (temp == null)
                              temp = "zaman aşımı oldu yada nfc donanımı yok";

                            setState(() {
                              _cardId = temp!;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("Toast"),
                        IconButton(
                          icon: Icon(Icons.today_sharp),
                          onPressed: () async {
                            BaseHelper.toastMessage("deneme toast mesaj");
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("Message"),
                        IconButton(
                          icon: Icon(Icons.message),
                          onPressed: () async {
                            BaseHelper.messageBox(context, "deneme title");
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("Message2"),
                        IconButton(
                          icon: Icon(Icons.message),
                          onPressed: () async {
                            BaseHelper.messageBox(
                                context, "deneme title", "deneme mesaj");
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("Message3"),
                        IconButton(
                          icon: Icon(Icons.message),
                          onPressed: () async {
                            BaseHelper.messageBox(context, "deneme title",
                                "deneme mesaj", SweetAlertStyle.error);
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("Confirm"),
                        IconButton(
                          icon: Icon(Icons.confirmation_number_outlined),
                          onPressed: () async {
                            BaseHelper.confirm(
                                context,
                                "deneme title",
                                "deneme mesaj",
                                SweetAlertStyle.confirm, (isConfirm) {
                              print("cevap");
                              print(isConfirm);
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("Device Security"),
                        IconButton(
                          icon: Icon(Icons.security),
                          onPressed: () async {
                            if (kIsWeb) {
                              BaseHelper.toastMessage(
                                  "browser güvenlik kontrolü yapılamaz");
                              return;
                            }

                            bool? a = await BaseHelper.jailBreakControl();
                            bool? a1 = await BaseHelper.realDeviceControl();
                            bool? a2 = await BaseHelper.mockLocationControl();
                            bool? a3 = await BaseHelper
                                .installedExternalStorageControl();
                            bool? a4 =
                                await BaseHelper.generalSecurityControl();

                            var qwea = 22;
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("Device Info"),
                        IconButton(
                          icon: Icon(Icons.info),
                          onPressed: () async {
                            dynamic test = await BaseHelper.getDeviceInfo();
                            print(test);
                            print(test["deviceType"]);
                            var qwea = 22;
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("Çökme kontrol"),
                        IconButton(
                          icon: Icon(Icons.delete_forever_outlined),
                          onPressed: () async {
                            if (kIsWeb) {
                              BaseHelper.toastMessage(
                                  "Trayıcı çökme kontrolü yapılamaz!");
                              return;
                            }

                            print("çöküyor");
                            FirebaseCrashlytics.instance.crash();
                            print("çöktü");
                            var qwea = 22;
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("Manuel hata"),
                        IconButton(
                          icon: Icon(Icons.delete_forever_outlined),
                          onPressed: () async {
                            print("manuel err");
                            try {
                              throw Error();
                            } catch (e) {
                              LogHelper.error(
                                  "kötü bişey oldu: " + e.toString());
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("Manuel log ve çökme"),
                        IconButton(
                          icon: Icon(Icons.delete_forever_outlined),
                          onPressed: () async {
                            if (kIsWeb) {
                              BaseHelper.toastMessage(
                                  "Trayıcı çökme kontrolü yapılamaz!");
                              return;
                            }

                            print("log");
                            LogHelper.error("manuel bir hatanın logu bu");
                            FirebaseCrashlytics.instance.crash();
                            print("log2");
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("App info"),
                        IconButton(
                          icon: Icon(Icons.info_outlined),
                          onPressed: () async {
                            print("inf");
                            var a = await BaseHelper.getAppInfo();
                            if (a == null) return;

                            print(a.packageName);
                            print("info");
                            var qwea = 22;
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("dinamik link"),
                        IconButton(
                          icon: Icon(Icons.add_link),
                          onPressed: () async {
                            print("dinamik link");

                            String? url = await BaseHelper.getFirebaseDynamicLink(
                                "https://angaryos.omersavas.com/second?key=yeni_uretim",
                                "angaryos kısa link",
                                "kısa link açıklaması");
                            print(url);
                            var qwea = 22;
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text("remote conf"),
                        IconButton(
                          icon: Icon(Icons.get_app),
                          onPressed: () async {
                            print("remote conf");

                            String? a =
                                await BaseHelper.getFirebaseRemoteConfig(
                                    "sesSeviyesi");
                            print(a);

                            a = await BaseHelper.getFirebaseRemoteConfig(
                                "testKey");
                            print(a);

                            a = await BaseHelper.getFirebaseRemoteConfig(
                                "geçersizKey");
                            print(a);

                            var qwea = 22;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
