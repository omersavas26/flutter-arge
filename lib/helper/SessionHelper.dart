import 'dart:io';
import 'package:angaryos/helper/LogHelper.dart';
import 'package:angaryos/helper/BaseHelper.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:dio/dio.dart';

class SessionHelper {
  //****    Variables    ****//

  static String token = "2b7qHuQ5zg479YiUd1";
  static bool disableSslCheck = true;
  static bool showAngaryosErrorMessage = true;

  //****    General    ****//

  static Future<Map<String, Object>> prepareDataForPost(
      Map<String, dynamic> data) async {
    Map<String, Object> temp = Map<String, Object>();

    for (String key in data.keys) {
      dynamic item = data[key];

      switch (item["type"]) {
        case "string":
          temp[key] = item["data"];
          break;
        case "fileBytes":
          List<MultipartFile> files = <MultipartFile>[];
          var fileBytes = item["data"];
          for (Map<String, dynamic> fData in fileBytes) {
            MultipartFile singleFile = await MultipartFile.fromBytes(
                fData["bytes"],
                filename: fData["name"]);
            files.add(singleFile);
          }
          temp[key] = files;
          break;
        case "filePaths":
          List<MultipartFile> files = <MultipartFile>[];
          var filePaths = item["data"];
          for (String filePath in filePaths) {
            MultipartFile singleFile = await MultipartFile.fromFile(filePath,
                filename: basename(filePath));
            files.add(singleFile);
          }

          temp[key] = files;
          break;
        default:
          LogHelper.error(await tr("httpPost data içinde geçersiz kolon tipi"),
              [key, data]);
      }
    }

    return temp;
  }

  static Future<String?> httpPost(String url, Map<String, dynamic> data,
      [bool? forceReturn]) async {
    String errorHtml = "";
    forceReturn ??= false;
    try {
      FormData formData = FormData.fromMap(await prepareDataForPost(data));
      var response =
          await Dio().post(url, data: formData).catchError((error) async {
        try {
          LogHelper.error(
              await tr("Http post içinde hata"), [error.toString(), url, data]);
          if (forceReturn!) errorHtml = error.response.toString();
        } catch (e) {
          LogHelper.error(await tr("Http post içinde hata") + ":",
              [e.toString(), url, data]);
        }
      });

      if (forceReturn) return response.toString();
      if (response.statusCode == 200) return response.toString();
      return null;
    } catch (e) {
      LogHelper.error(
          await tr("Http post içinde hata") + "::", [e.toString(), url, data]);
      if (errorHtml != "" && forceReturn) return errorHtml;
      return null;
    }
  }

  /*static Future<String?> httpPost(String url, dynamic data,
      [bool? forceReturn]) async {
    try {
      forceReturn ??= false;

      final response = await http.post(Uri.parse(url), body: data);

      if (forceReturn) return response.body;

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      LogHelper.error("Http post error", [e.toString(), url]);
      return null;
    }
  }*/

  static Future<dynamic> httpPostJson(String url, dynamic data,
      [bool? forceReturn]) async {
    String? jsonStr = await httpPost(url, data, forceReturn);
    if (jsonStr == null) return null;

    try {
      return BaseHelper.jsonStrToObject(jsonStr);
    } catch (e) {
      LogHelper.error(await tr("Http post içinde json parse edilemedi"),
          [e.toString(), url, data]);
      return forceReturn! ? jsonStr : null;
    }
  }

  static Future<dynamic> httpPostJsonA(String url, dynamic data,
      [bool? forceReturn]) async {
    dynamic obj = await httpPostJson(url, data, forceReturn);
    if (obj == null) return null;

    try {
      if (obj["status"] == "success") return obj["data"];

      if (obj["status"] == "error") {
        if (!await _angaryosResponseJsonCallback(obj) && forceReturn!)
          return obj["data"];
      }

      LogHelper.error(
          await tr("httpPostJsonA için geçersiz cevap"), [obj, data]);
      return forceReturn! ? obj : null;
    } catch (e) {}

    LogHelper.error(
        await tr("httpPostJsonA için geçersiz cevap") + ":", [obj, data]);
    return forceReturn! ? obj : null;
  }

  static Future<String?> httpGet(String url, [bool? forceReturn]) async {
    try {
      forceReturn ??= false;

      final response = await http.get(Uri.parse(url));

      if (forceReturn) return response.body;

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      LogHelper.error(await tr("Http get içinde hata"), [e.toString(), url]);
      return null;
    }
  }

  static Future<dynamic> httpGetJson(String url, [bool? forceReturn]) async {
    String? jsonStr = await httpGet(url, forceReturn);
    if (jsonStr == null) return null;

    try {
      return BaseHelper.jsonStrToObject(jsonStr);
    } catch (e) {
      LogHelper.error(await tr("Http get içinde json parse edilemedi"),
          [e.toString(), url]);
      return forceReturn! ? jsonStr : null;
    }
  }

  static Future<dynamic> httpGetJsonA(String url, [bool? forceReturn]) async {
    dynamic obj = await httpGetJson(url, forceReturn);
    if (obj == null) return null;

    try {
      if (obj["status"] == "success") return obj["data"];

      if (obj["status"] == "error") {
        if (!await _angaryosResponseJsonCallback(obj) && forceReturn!)
          return obj["data"];
      }

      LogHelper.error(await tr("httpGetJsonA için geçersiz cevap"), obj);
      return forceReturn! ? obj : null;
    } catch (e) {}

    LogHelper.error(await tr("httpGetJsonA için geçersiz cevap"), obj);
    return forceReturn! ? obj : null;
  }

  static Future<bool> _angaryosResponseJsonCallback(dynamic obj) async {
    switch (obj["data"]["message"]) {
      case "fail.token":
        BaseHelper.redirectToLoginUrl();
        return false;
      default:
        if (showAngaryosErrorMessage == false)
          LogHelper.error(await tr("Sunucudan bir hata mesajı döndü"), obj);
        else
          BaseHelper.toastMessage(await tr("Sunucudan bir hata mesajı döndü") +
              ": " +
              obj["data"]["message"]);
        return false;
    }
  }

  static String getBaseUrlWithToken() {
    return BaseHelper.backendBaseUrl + token + "/";
  }
}

class AngaryosHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
              SessionHelper.disableSslCheck;
  }
}
