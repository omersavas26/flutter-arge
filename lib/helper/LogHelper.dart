import 'package:angaryos/helper/BaseHelper.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class LogHelper {
  //****    Variables    ****//

  static bool debug = BaseHelper.debug;
  static bool writeToLocal = true;
  static bool showToast = true;

  //****    General    ****//

  static void info(String log, [dynamic data]) {
    if (!debug) return;

    log = logToString("INFO", log, data);

    print(log);
    if (showToast) BaseHelper.toastMessage(log);
    if (!kIsWeb) BaseHelper.sendFirebaseCrashlyticsLog(log);
  }

  static void error(String log, [dynamic data]) {
    log = logToString("ERROR", log, data);

    print(log);
    if (!kIsWeb) BaseHelper.sendFirebaseCrashlyticsLog(log);
    if (showToast) BaseHelper.toastMessage(log);

    if (!writeToLocal) return;

    String key =
        "log_" + DateFormat("yyyy_MM_dd_hh_mm_SSSS").format(DateTime.now());

    BaseHelper.writeToLocal(key, log);
  }

  //****    Common    ****//

  static String logToString(String level, String log, [dynamic data]) {
    String time = DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now());
    log = level + " - " + time + ": " + log;

    if (data != null) log += " -> " + BaseHelper.objectToJsonStr(data);

    return log;
  }
}
