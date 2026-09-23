// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:purchases_flutter/purchases_flutter.dart';

Future<String?> getRevenueCatUserId() async {
  try {
    // جلب الـ App User ID المباشر والفعلي من RevenueCat
    String appUserId = await Purchases.appUserID;
    return appUserId;
  } catch (e) {
    // في حالة حدوث أي خطأ يرجع قيمة فارغة حتى لا يتوقف التطبيق
    return '';
  }
}
