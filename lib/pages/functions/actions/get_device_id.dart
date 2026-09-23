// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

Future<String?> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo android = await deviceInfo.androidInfo;
    return android.id;
  } else if (Platform.isIOS) {
    IosDeviceInfo ios = await deviceInfo.iosInfo;
    return ios.identifierForVendor;
  }
  return null;
}
