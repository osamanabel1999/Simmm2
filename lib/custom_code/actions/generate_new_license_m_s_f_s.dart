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
import 'dart:math';
import 'package:http/http.dart' as http;

Future<String> generateNewLicenseMSFS(
    String? duration, String? appUserId) async {
  const String token =
      'patZuFHBTfOuzMmP7.b473d75321c56e35e5f7c0d76fcc330098903b08fabc3860400953058a89e39d';
  const String baseId = 'appmz3issohHsNLRM';
  const String tableId = 'tblse0E5FhASxuhmn';

  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  String newCode =
      List.generate(8, (index) => chars[Random().nextInt(chars.length)]).join();

  const String simType = 'MSFS';

  final String currentDuration = (duration == null || duration.trim().isEmpty)
      ? '1_month'
      : duration.trim().toLowerCase();

  final String cleanUserId = (appUserId == null) ? '' : appUserId.trim();

  // تحديد نوع الباقة باللغة الإنجليزية فقط
  String cleanPlanType = 'Monthly';

  if (currentDuration == '1_year' ||
      currentDuration == '12_months' ||
      currentDuration == 'yearly') {
    cleanPlanType = 'Yearly';
  } else if (currentDuration == 'lifetime') {
    cleanPlanType = 'Lifetime';
  }

  // حساب تاريخ الانتهاء بصيغة YYYY-MM-DD أو كتابة Lifetime
  DateTime now = DateTime.now();
  String expiryDateOnlyStr;

  if (cleanPlanType == 'Lifetime') {
    expiryDateOnlyStr = 'Lifetime';
  } else if (cleanPlanType == 'Yearly') {
    DateTime nextYear = DateTime(now.year + 1, now.month, now.day);
    expiryDateOnlyStr =
        "${nextYear.year.toString().padLeft(4, '0')}-${nextYear.month.toString().padLeft(2, '0')}-${nextYear.day.toString().padLeft(2, '0')}";
  } else {
    // الشهري (نضيف شهر واحد)
    DateTime nextMonth = DateTime(now.year, now.month + 1, now.day);
    expiryDateOnlyStr =
        "${nextMonth.year.toString().padLeft(4, '0')}-${nextMonth.month.toString().padLeft(2, '0')}-${nextMonth.day.toString().padLeft(2, '0')}";
  }

  final url = Uri.parse('https://api.airtable.com/v0/$baseId/$tableId');

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'typecast': true,
        'fields': {
          'LicenseKey': newCode,
          'Duration': currentDuration,
          'PlanType': cleanPlanType,
          'SimType': simType,
          'AppUserID': cleanUserId,
          'ExpiryDateOnly': expiryDateOnlyStr,
        }
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return newCode;
    } else {
      return "Status ${response.statusCode}: ${response.body}";
    }
  } catch (e) {
    return "Error: $e";
  }
}
