import 'dart:async';
import 'dart:io';

import 'package:angaryos/view/TakePicturePage.dart';
import 'package:angaryos/view/TakePicturePageWeb.dart';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:trust_fall/trust_fall.dart';
import 'package:universal_html/html.dart' as html;
import 'package:geolocator/geolocator.dart';
import 'LogHelper.dart';
import 'package:reflectable/reflectable.dart';

class Reflector extends Reflectable {
  const Reflector()
      : super(invokingCapability); // Request the capability to invoke methods.
}

const reflector = const Reflector();

class BaseHelper {
  //****    Variables    *****//

  static String backendBaseUrl = "https://192.168.10.185/api/v1/";
  static String firebaseDynamicLinkDomain = "https://angaryos.page.link";
  static String firebaseCMMainTopic = "angaryos_test";
  static String? firebaseCMToken = null;

  static var availableLanguages = ["tr", "en", "ar"];
  static String defaultLanguage = "tr";
  static String currentLanguage = "tr";
  static String currentUrl = "";
  static String currentUrlFull = "";
  static BuildContext? context;
  static Map<String, dynamic> languages = {};
  static final _secureLocalStorage = new FlutterSecureStorage();
  static final html.Storage? _localStorage =
      kIsWeb ? html.window.localStorage : null;
  static dynamic pipe;
  static bool debug = true;
  static String? lastCardId;
  static FirebaseApp? fireBaseApp;
  static Future<FirebaseApp>? fireBaseAppAsync;
  static PackageInfo? appInfo = null;
  static AndroidNotificationChannel? _androidNotificationChannel;
  static FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;
  static RemoteConfig? remoteConfig;
  static Map<String, dynamic> defaultConfigs = <String, dynamic>{
    'sesSeviyesi': 'az',
    'denemSayisi': 22,
  };

  //****    General    *****//

  static Future<bool> mobileControl([bool? message]) async {
    if (!kIsWeb) return true;

    message ??= true;
    if (message)
      toastMessage(await tr("Bu özellik tarayıcı için kullanılamaz!"));
    return false;
  }

  static Future<bool> iosControl([bool? message]) async {
    if (!kIsWeb && Platform.isIOS) return true; 

    message ??= true;
    if (message)
      toastMessage(await tr("Bu özellik IOS için kullanılamaz!"));
    return false;
  }

  static Future<void> sleep(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  static Future<PackageInfo?> getAppInfo() async {
    if (!await mobileControl()) return null;

    if (appInfo == null) appInfo = await PackageInfo.fromPlatform();
    return appInfo!;
  }

  static void setActiveContext(cntx) async {
    context = cntx;
  }

  //****    Navigation    ****//

  static void redirectToBaseUrl() {
    Navigator.of(context!).pushNamed("/" + BaseHelper.defaultLanguage + "/");
  }

  static void navigate(String name) {
    if (name.substring(0, 1) == "/") name = name.substring(1);
    toastMessage("navigate: " + name);
    Navigator.of(context!).pushNamed(
        "/" + BaseHelper.currentLanguage + "/" + name,
        arguments: "");
  }

  static void redirectToLoginUrl() {
    /*Navigator.of(context!).pushNamed("/" + BaseHelper.defaultLanguage + "/login");*/
    toastMessage("logine yönlendir.");
  }

  static List<String>? parseAndValidateUrl(String url) {
    if (url.substring(0, 1) != '/') url = "/" + url;
    List<String> rt = url.split("/");

    if (rt.length < 2 || rt[1].length != 2) redirectToBaseUrl();
    if (!availableLanguages.contains(rt[1])) redirectToBaseUrl();

    return rt;
  }

  //****    Language    ****//

  static String getCurrentLanguage(String url) {
    currentUrl = url;
    currentLanguage = parseAndValidateUrl(url)![1];
    return currentLanguage;
  }

  static Future<bool> loadLanguage(language, [bool? force]) async {
    if (!availableLanguages.contains(language)) return false;

    force ??= false;

    if (languages.containsKey(language) && force == false) return true;

    try {
      String data = await DefaultAssetBundle.of(context!)
          .loadString("assets/localization/" + language + ".json");
      languages[language] = jsonStrToObject(data);
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  static dynamic getLanguageObject(String language) async {
    if (!availableLanguages.contains(language)) return null;

    if (!languages.containsKey(language)) {
      await loadLanguage(language);
    }
    return languages[language];
  }

  static Future<String> getTranslatedTextAsync(String key,
      [String? language]) async {
    language ??= currentLanguage;

    dynamic data = await getLanguageObject(language);

    try {
      var temp = data[key];
      if (temp != null) return temp;
    } catch (e) {}

    return language + ":" + key;
  }

  static FutureBuilder<String> getTranslatedTextWidget(String key,
      [String? language]) {
    return FutureBuilder<String>(
      future: getTranslatedTextAsync(key, language),
      builder: (BuildContext context, AsyncSnapshot<String> ss) {
        if (ss.hasData)
          return Text(ss.data!);
        else if (ss.hasError)
          return Text(key);
        else
          return Text(key);
      },
    );
  }

  //****    Data    ****//

  static String objectToJsonStr(dynamic obj) {
    return json.encode(obj);
  }

  static dynamic jsonStrToObject(String str) {
    return json.decode(str);
  }

  static void writeToPipe(String key, dynamic value) {
    pipe[key] = value;
  }

  static void readFromPipe(String key) {
    return pipe[key];
  }

  static Future<void> writeToLocal(String key, dynamic value,
      [int? timeOut]) async {
    timeOut ??= -1;
    if (timeOut == 0) return;

    var obj = {"data": value, "timeOut": timeOut};

    if (timeOut > 0)
      obj["startTime"] =
          DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now());

    String jsonStr = objectToJsonStr(obj);

    if (kIsWeb)
      _localStorage![key] = encode(jsonStr);
    else
      _secureLocalStorage.write(key: key, value: jsonStr);
  }

  static bool _getLocalDataExpiration(obj) {
    if (obj["timeOut"] < 0) return true;

    DateTime startTime =
        new DateFormat("yyyy-MM-dd hh:mm:ss").parse(obj["startTime"]);
    DateTime now = DateTime.now();

    int interval = now.difference(startTime).inMilliseconds;

    return interval < obj["timeOut"];
  }

  static Future<dynamic> readFromLocal(String key) async {
    String? jsonStr;

    if (kIsWeb)
      jsonStr = decode(_localStorage![key]);
    else
      jsonStr = await _secureLocalStorage.read(key: key);

    if (jsonStr == null) return null;

    dynamic obj = jsonStrToObject(jsonStr);

    if (_getLocalDataExpiration(obj))
      return obj["data"];
    else {
      if (kIsWeb)
        _localStorage!.remove(key);
      else
        _secureLocalStorage.delete(key: key);
      return null;
    }
  }

  static String encode(String? data) {
    return data!;
  }

  static String decode(String? data) {
    return data!;
  }

  //****    Location    ****//

  static Future<bool> locationServiceControl([bool? showMessage]) async {
    showMessage ??= true;

    bool control = await Geolocator.isLocationServiceEnabled();
    if (!control && showMessage)
      toastMessage(await tr("Konumuz alınamadı! GPS kapalı olabilir."));

    return control;
  }

  static Future<Position?> getLocation() async {
    bool control = await locationServiceControl();
    if (!control) return null;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  static Future<Position?> getLocationFromCache() async {
    bool control = await locationServiceControl();
    if (!control) return null;

    Position? position = await Geolocator.getLastKnownPosition();
    return position;
  }

  static Future<void> trackLocation(
      Null Function(ServiceStatus? vars) callback) async {
    Geolocator.getServiceStatusStream().listen(callback);
  }

  //****    Message    ****//

  static void toastMessage(String? message) {
    Fluttertoast.showToast(
        msg: message!,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  static void messageBox(context, String title,
      [String? subtitle, SweetAlertStyle? style]) {
    style ??= SweetAlertStyle.success;
    SweetAlert.show(context, title: title, subtitle: subtitle, style: style);
  }

  static void confirm(context, String title,
      [String? subtitle,
      SweetAlertStyle? style,
      Null Function(bool vars)? callback]) async {
    style ??= SweetAlertStyle.confirm;
    SweetAlert.show(context,
        title: title,
        subtitle: subtitle,
        style: style,
        showCancelButton: true,
        onPress: callback);
  }

  //****    Media    ****/

  static Future<List<dynamic>?> getFilesFromLibrary(int count,
      [String? fileTypes]) async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(allowMultiple: count > 1);
      if (result == null) return null;

      fileTypes ??= "*";

      List<String> typeArray = [];
      if (fileTypes != "*") {
        for (String type in fileTypes.split("|")) {
          typeArray.add(type.toLowerCase());
        }
      }

      List<dynamic> files = [];

      for (PlatformFile? file in result.files) {
        if (file == null) continue;

        String? ext = basename(file.name).split(".").last.toLowerCase();
        if (fileTypes != "*" && !typeArray.contains(ext)) {
          toastMessage(await tr(
              "Seçilen dosyalar içinde geçersiz tipte dosya var. Dosya dikkate alınmadı!"));
          continue;
        }

        if (count-- == 0) break;

        files.add(file);
      }

      return files.length == 0 ? null : files;
    } catch (e) {
      LogHelper.error(await tr("Method içinde hata: ") + "getFilesFromLibrary",
          e.toString());
    }
  }

  static Future<File?> takePhotoFromCamera(context) async {
    if (kIsWeb) {
      toastMessage(await tr("Kamera şidilik web için kullanılamıyor..."));
      return null;
      //return await Navigator.push(context,  MaterialPageRoute(builder: (context) => TakePicturePageWeb()));
    } else {
      var temp = await availableCameras();
      if(temp.length == 0){
        toastMessage(await tr("Cihazınızda kamera yok!"));
        return null;
      }

      return await Navigator.push(
          context, MaterialPageRoute(builder: (context) => TakePicturePage()));
    }
  }

  //****    NFC    ****//

  static Future<bool> nfcServiceControl([bool? showMessage]) async {
    if (!await mobileControl()) return false;

    showMessage ??= true;
    bool control = await NfcManager.instance.isAvailable();
    if (!control && showMessage)
      toastMessage(await tr("Cihazınızda NFC yok yada kapalı!"));

    return control;
  }

  static Future<String?> getCardId() async {
    bool control = await nfcServiceControl();
    if (!control) return null;

    lastCardId = null;

    startCardListen();

    for (var i = 0; i < 10; i++) {
      await sleep(500);
      if (lastCardId != null) return lastCardId;
    }

    stopCardListen();
  }

  static Future<void> startCardListen() async {
    bool control = await nfcServiceControl();
    if (!control) return null;

    FlutterNfcReader.read().then((response) async {
      LogHelper.info(await tr("RFID kart okundu"), response.id);
      lastCardId = response.id;
      stopCardListen();
    });

    toastMessage(await tr("Cihazınızı karta yaklaştırınız"));
  }

  static Future<void> stopCardListen() async {
    await FlutterNfcReader.stop();
  }

  //****    Device Security    ****/

  static Future<bool?> jailBreakControl() async {
    if (!await mobileControl()) return null;
    return TrustFall.isJailBroken;
  }

  static Future<bool?> realDeviceControl() async {
    if (!await mobileControl()) return null;
    return TrustFall.isRealDevice;
  }

  static Future<bool?> mockLocationControl() async {
    if (!await mobileControl()) return null;
    return TrustFall.canMockLocation;
  }

  static Future<bool?> installedExternalStorageControl() async {
    if (!await mobileControl()) return null;
    if (await iosControl()) return null;

    return TrustFall.isOnExternalStorage;
  }

  static Future<bool?> generalSecurityControl() async {
    if (!await mobileControl()) return null;

    bool? control = await jailBreakControl();
    if (control!) return false;

    control = await realDeviceControl();
    if (!control!) return false;

    control = await mockLocationControl();
    if (control!) return false;

    control = await installedExternalStorageControl();
    if (control!) return false;

    return true;
  }

  static Future<dynamic>? getDeviceInfo() async {
    if (kIsWeb)
      return getDeviceInfoBrowser();
    else if (Platform.isAndroid)
      return getDeviceInfoAndroid();
    else if (Platform.isIOS) return getDeviceInfoIos();
  }

  static Future<dynamic>? getDeviceInfoAndroid() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    return {
      "deviceType": "android",
      "deviceId": androidInfo.androidId,
      "device": androidInfo.device,
      "id": androidInfo.id,
      "isPhysicalDevice": androidInfo.isPhysicalDevice,
      "model": androidInfo.model,
      "product": androidInfo.product,
      "type": androidInfo.type,
      "version": androidInfo.version
    };
  }

  static Future<dynamic>? getDeviceInfoIos() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

    return {
      "deviceType": "ios",
      "name": iosInfo.name,
      "identifierForVendor": iosInfo.identifierForVendor,
      "isPhysicalDevice": iosInfo.isPhysicalDevice,
      "localizedModel": iosInfo.localizedModel,
      "model": iosInfo.model,
      "systemName": iosInfo.systemName,
      "utsname": iosInfo.utsname
    };
  }

  static Future<dynamic>? getDeviceInfoBrowser() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;

    return {
      "deviceType": "browser",
      "appCodeName": webBrowserInfo.appCodeName,
      "appName": webBrowserInfo.appName,
      "appVersion": webBrowserInfo.appVersion,
      "browserName": webBrowserInfo.browserName,
      "language": webBrowserInfo.language,
      "platform": webBrowserInfo.platform,
      "product": webBrowserInfo.product,
      "productSub": webBrowserInfo.productSub,
      "userAgent": webBrowserInfo.userAgent
    };
  }

  //****    Local Notifications    ****//

  static Future<void> _localNotificationOperations() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await _flutterLocalNotificationsPlugin!
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidNotificationChannel!);

    //ios
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static void sendLocalNotification(int id, String? title, String? body) async {
    if (!await mobileControl()) return null;

    if (_androidNotificationChannel == null) fillAndroidNotificationChannel();

    _flutterLocalNotificationsPlugin!.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidNotificationChannel!.id,
            _androidNotificationChannel!.name,
            _androidNotificationChannel!.description,
            icon: 'launch_background',
          ),
        ));
  }

  //****    Firebase    ****//

  static Future<void> firebaseOperations([bool? logEnable]) async {
    BaseHelper.fireBaseAppAsync = Firebase.initializeApp();
    BaseHelper.fireBaseApp = await BaseHelper.fireBaseAppAsync;

    if (!kIsWeb) await _firebaseCrashlyticsOperations(logEnable);
    await _firebaseCMOperations();
    if (!kIsWeb) await _localNotificationOperations();
    if (!kIsWeb) await _firebaseRemoteConfigOperations();
  }

  //****    Firebase Crashlytics    ****/

  static Future<void> _firebaseCrashlyticsOperations([bool? logEnable]) async {
    logEnable ??= true;
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(logEnable);

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }

  static void setFirebaseCrashlyticsUser(String user) async {
    if (!await mobileControl()) return null;
    FirebaseCrashlytics.instance.setUserIdentifier(user);
  }

  static void sendFirebaseCrashlyticsLog(String log) async {
    if (!await mobileControl()) return null;
    FirebaseCrashlytics.instance.log(log);
  }

  //****    Firebase Cloud Messaging    ****//

  static Future<void> _firebaseCMOperations() async {
    await firebaseCMSubscribe(firebaseCMMainTopic);
    //await firebaseCMUnsubscribe(firebaseCMMainTopic);

    await _fillFirebaseCMVariables();

    FirebaseMessaging.onBackgroundMessage(_firebaseCMBackgroundHandler);

    FirebaseMessaging.instance
        .getInitialMessage()
        .then(_firebaseCMForegroundBeforeHandler);

    FirebaseMessaging.onMessage.listen(_firebaseCMForegroundAfterHandler);

    FirebaseMessaging.onMessageOpenedApp
        .listen(_firebaseCMNotifyClickedHandler);
  }

  static Future<void> firebaseCMSubscribe(String topic) async {
    if (kIsWeb) return;
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static Future<void> firebaseCMUnsubscribe(String topic) async {
    if (kIsWeb) return;
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  static Future<void> fillFirebaseCMToken() async {
    if (firebaseCMToken != null) return;
    firebaseCMToken = await FirebaseMessaging.instance.getToken();
    LogHelper.info("Firebase CM token: " + firebaseCMToken!);

    //ios?
    //String? token2 = await FirebaseMessaging.instance.getAPNSToken();
  }

  static void logInfoForFirebaseRemoteMessage(
      String handler, RemoteMessage message) {
    String? b = message.notification!.body;
    String? t = message.notification!.title;
    Map<String, dynamic> d = message.data;
    toastMessage(handler);
    LogHelper.info("logInfoForFirebaseRemoteMessage:" + handler, [t, b, d]);
  }

  static void controlFirebaseRemoteMessage(
      String handler, RemoteMessage message) async {
    logInfoForFirebaseRemoteMessage(handler, message);

    Map<String, dynamic> d = message.data;
    if (!d.containsKey("path")) return;

    await sleep(1000);
    navigate(d["path"]);
  }

  static void fillAndroidNotificationChannel() {
    _androidNotificationChannel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );
  }

  static Future<void> _fillFirebaseCMVariables() async {
    await fillFirebaseCMToken();
    if (!kIsWeb) fillAndroidNotificationChannel();
  }

  static Future<void> _firebaseCMBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    controlFirebaseRemoteMessage("_firebaseCMBackgroundHandler", message);
  }

  static Future<void> _firebaseCMForegroundBeforeHandler(
      RemoteMessage? message) async {
    if (message == null) return;
    controlFirebaseRemoteMessage("_firebaseCMForegroundBeforeHandler", message);
  }

  static Future<void> _firebaseCMForegroundAfterHandler(
      RemoteMessage? message) async {
    RemoteNotification? notification = message!.notification;
    //AndroidNotification? android = message.notification?.android;
    sendLocalNotification(
        notification.hashCode, notification!.title, notification.body);

    logInfoForFirebaseRemoteMessage(
        "_firebaseCMForegroundAfterHandler", message);
  }

  static Future<void> _firebaseCMNotifyClickedHandler(
      RemoteMessage message) async {
    controlFirebaseRemoteMessage("_firebaseCMNotifyClickedHandler", message);
  }

  //****    Firebase Dynamic Links   ****//

  static Future<String?> getFirebaseDynamicLink(
      String link, String title, String description,
      [bool? short]) async {
    if (!await mobileControl()) return null;

    PackageInfo? info = await getAppInfo();
    DynamicLinkParameters? params = DynamicLinkParameters(
        uriPrefix: firebaseDynamicLinkDomain,
        link: Uri.parse(link),
        androidParameters: AndroidParameters(
            packageName: info!.packageName, minimumVersion: 0),
        /*iosParameters: IosParameters(
          bundleId: info.packageName,
          minimumVersion: '1.0.1',
          appStoreId: '123456789',
        ),*/
        dynamicLinkParametersOptions: DynamicLinkParametersOptions(
            shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short),
        socialMetaTagParameters:
            SocialMetaTagParameters(title: title, description: description));

    short ??= true;
    if (short) {
      var temp = await params.buildShortLink();
      return temp.shortUrl.toString();
    } else {
      return (await params.buildUrl()).toString();
    }
  }

  static Future<void> firebaseDynamicLinkControl() async {
    final PendingDynamicLinkData? dynamicLink =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (dynamicLink != null) _handleFirabaseDynamicLink(dynamicLink);

    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData? dynamicLink) async {
        _handleFirabaseDynamicLink(dynamicLink);
      },
      onError: (OnLinkErrorException e) async {
        LogHelper.error(
            await tr("Method içinde hata: ") + "firebaseDynamicLinkControl",
            e.toString());
      },
    );
  }

  static Future<void> _handleFirabaseDynamicLink(
      PendingDynamicLinkData? data) async {
    if (data == null) return;

    String path = data.link.path + "?" + data.link.query;
    navigate(path);
  }

  //****    Firebase Remote Config    ****//

  static Future<void> _firebaseRemoteConfigOperations() async {
    await Firebase.initializeApp();
    final RemoteConfig conf = RemoteConfig.instance;
    await conf.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await conf.setDefaults(defaultConfigs);

    RemoteConfigValue(null, ValueSource.valueStatic);

    remoteConfig = conf;
  }

  static Future<String?> getFirebaseRemoteConfig(String key) async {
    if (!await mobileControl()) return null;
    return remoteConfig!.getString(key);
  }
}

var trW = BaseHelper.getTranslatedTextWidget;
var tr = BaseHelper.getTranslatedTextAsync;
