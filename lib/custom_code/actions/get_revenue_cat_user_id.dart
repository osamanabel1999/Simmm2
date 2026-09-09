// Automatic FlutterFlow imports
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
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
