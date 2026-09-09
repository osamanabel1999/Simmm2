// Automatic FlutterFlow imports
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

Future<String> restoreLicenseXPlane() async {
  const String token =
      'patZuFHBTfOuzMmP7.b473d75321c56e35e5f7c0d76fcc330098903b08fabc3860400953058a89e39d';
  const String baseId = 'appmz3issohHsNLRM';
  const String tableName = 'Table 1';

  // 1. جلب رقم الجهاز الحقيقي
  String deviceId = '';
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'unknown_ios';
    }
  } catch (e) {
    deviceId = 'unknown_device';
  }

  if (deviceId == 'unknown_device' || deviceId.isEmpty) {
    return "Error: Could not retrieve device ID.";
  }

  // 2. البحث في Airtable برقم الجهاز في جدول Table 1
  final queryUrl = Uri.parse(
      'https://api.airtable.com/v0/$baseId/${Uri.encodeComponent(tableName)}?filterByFormula={DeviceID}="$deviceId"');

  try {
    final response = await http.get(queryUrl, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      return "Error connecting to server.";
    }

    final data = json.decode(response.body);
    final List records = data['records'] ?? [];

    if (records.isEmpty) {
      return "No subscription found for this device.";
    }

    // 3. البحث بين جميع السجلات التابعة للجهاز عن رخصة صالحة وغير منتهية
    String? validLicenseKey;
    String? validExpiryDate;

    for (var record in records) {
      final fields = record['fields'];
      final String? key = fields['LicenseKey'];
      final String? expiresAtStr = fields['ExpiresAt'];

      if (key == null || key.trim().isEmpty) continue;

      // لو الرخصة Lifetime
      if (expiresAtStr != null && expiresAtStr.toLowerCase() == 'lifetime') {
        validLicenseKey = key;
        validExpiryDate = 'Lifetime';
        break; // الرخصة الدائمة لها الأولوية القصوى
      }

      // لو الرخصة لها تاريخ انتهاء
      if (expiresAtStr != null && expiresAtStr.isNotEmpty) {
        try {
          DateTime expiryDate = DateTime.parse(expiresAtStr);
          if (DateTime.now().isBefore(expiryDate)) {
            // رخصة صالحة ومستمرة
            validLicenseKey = key;
            validExpiryDate = expiresAtStr;
            break;
          }
        } catch (e) {}
      }
    }

    // لو ملقيناش أي رخصة شغالة
    if (validLicenseKey == null) {
      return "License Expired.";
    }

    // تحويل التاريخ لصيغة YYYY-MM-DD
    String formatDateOnly(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return 'Lifetime';
      if (dateStr.toLowerCase() == 'lifetime') return 'Lifetime';
      try {
        DateTime dt = DateTime.parse(dateStr);
        String year = dt.year.toString();
        String month = dt.month.toString().padLeft(2, '0');
        String day = dt.day.toString().padLeft(2, '0');
        return "$year-$month-$day";
      } catch (e) {
        return dateStr;
      }
    }

    // حفظ تاريخ الانتهاء في App State الخاص بـ XPlane
    try {
      (FFAppState() as dynamic).licenseExpiryDateXPlane =
          formatDateOnly(validExpiryDate);
    } catch (_) {}

    // إرجاع أحدث كود رخصة صالح
    return validLicenseKey;
  } catch (e) {
    return "Error: $e";
  }
}
