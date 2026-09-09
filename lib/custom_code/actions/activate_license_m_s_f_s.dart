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

Future<String> activateLicenseMSFS(String licenseCode) async {
  if (licenseCode.trim().isEmpty) {
    return "Invalid License Key.";
  }

  const String token =
      'patZuFHBTfOuzMmP7.b473d75321c56e35e5f7c0d76fcc330098903b08fabc3860400953058a89e39d';
  const String baseId = 'appmz3issohHsNLRM';
  const String tableName = 'tblse0E5FhASxuhmn';

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

  final queryUrl = Uri.parse(
      'https://api.airtable.com/v0/$baseId/${Uri.encodeComponent(tableName)}?filterByFormula={LicenseKey}="$licenseCode"');

  final response = await http.get(queryUrl, headers: {
    'Authorization': 'Bearer $token',
  });

  if (response.statusCode != 200) {
    return "Error connecting to server.";
  }

  final data = json.decode(response.body);
  final List records = data['records'] ?? [];

  if (records.isEmpty) {
    return "Invalid License Key.";
  }

  final record = records[0];
  final String recordId = record['id'];
  final fields = record['fields'];

  final String? keyInTable = fields['LicenseKey'];
  if (keyInTable == null || keyInTable.trim().isEmpty) {
    return "Invalid License Key.";
  }

  final bool isUsed = fields['IsUsed'] ?? false;
  final String? storedDeviceId = fields['DeviceID'];
  final String? duration = fields['Duration'];
  final String? expiresAtStr = fields['ExpiresAt'];

  // دالة تحويل التاريخ لـ يوم-شهر-سنة فقط
  String formatDateOnly(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Lifetime';
    if (dateStr.toLowerCase() == 'lifetime') return 'Lifetime';
    try {
      DateTime dt = DateTime.parse(dateStr);
      String year = dt.year.toString();
      String month = dt.month.toString().padLeft(2, '0');
      String day = dt.day.toString().padLeft(2, '0');
      return "$year-$month-$day"; // الشكل النهائي: YYYY-MM-DD
    } catch (e) {
      return dateStr;
    }
  }

  if (isUsed) {
    if (storedDeviceId != deviceId) {
      return "This key is already used on another device.";
    }

    if (expiresAtStr != null && expiresAtStr.isNotEmpty) {
      try {
        DateTime expiryDate = DateTime.parse(expiresAtStr);
        if (DateTime.now().isAfter(expiryDate)) {
          return "License Expired.";
        }
      } catch (e) {}
    }

    // حفظ التاريخ بصيغة يوم/شهر/سنة في App State عند إعادة التفعيل
    FFAppState().licenseExpiryDateMSFS = formatDateOnly(expiresAtStr);

    return "Success";
  } else {
    String? newExpiresAt;
    DateTime now = DateTime.now();

    if (duration != null) {
      switch (duration.toLowerCase().trim()) {
        case '1_day':
        case 'day':
          newExpiresAt = now.add(const Duration(days: 1)).toIso8601String();
          break;
        case '1_week':
        case 'week':
          newExpiresAt = now.add(const Duration(days: 7)).toIso8601String();
          break;
        case '1_month':
        case 'month':
          newExpiresAt = now.add(const Duration(days: 30)).toIso8601String();
          break;
        case '3_months':
        case '3months':
          newExpiresAt = now.add(const Duration(days: 90)).toIso8601String();
          break;
        case '1_year':
        case 'year':
          newExpiresAt = now.add(const Duration(days: 365)).toIso8601String();
          break;
        case 'lifetime':
          newExpiresAt = 'Lifetime';
          break;
        default:
          newExpiresAt = null;
      }
    }

    final updateUrl = Uri.parse(
        'https://api.airtable.com/v0/$baseId/${Uri.encodeComponent(tableName)}/$recordId');

    Map<String, dynamic> updateFields = {
      'IsUsed': true,
      'DeviceID': deviceId,
    };
    if (newExpiresAt != null) {
      updateFields['ExpiresAt'] = newExpiresAt;
    }

    final updateResponse = await http.patch(
      updateUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'fields': updateFields}),
    );

    if (updateResponse.statusCode == 200) {
      // حفظ التاريخ بصيغة يوم/شهر/سنة في App State عند التفعيل أول مرة
      FFAppState().licenseExpiryDateMSFS = formatDateOnly(newExpiresAt);
      return "Success";
    } else {
      return "Activation failed. Try again.";
    }
  }
}
