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
import 'package:http/http.dart' as http;

Future<String> extendLicenseMSFS(String licenseCode, String? duration) async {
  if (licenseCode.trim().isEmpty) {
    return "Invalid License Key.";
  }

  const String token =
      'patZuFHBTfOuzMmP7.b473d75321c56e35e5f7c0d76fcc330098903b08fabc3860400953058a89e39d';
  const String baseId = 'appmz3issohHsNLRM';
  const String tableName = 'tblse0E5FhASxuhmn';

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
    return "License Key not found.";
  }

  final record = records[0];
  final String recordId = record['id'];
  final fields = record['fields'];
  final String? currentExpiresAtStr = fields['ExpiresAt'];

  // تحديد تاريخ البداية اللي هنزود عليه
  DateTime baseDate = DateTime.now();
  if (currentExpiresAtStr != null && currentExpiresAtStr.isNotEmpty) {
    try {
      DateTime currentExpiry = DateTime.parse(currentExpiresAtStr);
      // لو تاريخ الانتهاء الحالي لسه مخلصش، بنزود فوقه عشان اليوزر ما يخسرش أيام
      if (currentExpiry.isAfter(baseDate)) {
        baseDate = currentExpiry;
      }
    } catch (e) {}
  }

  DateTime newExpiresAtDate;
  String dur = (duration == null || duration.trim().isEmpty)
      ? '1_month'
      : duration.toLowerCase().trim();

  switch (dur) {
    case '1_day':
    case 'day':
      newExpiresAtDate = baseDate.add(const Duration(days: 1));
      break;
    case '1_week':
    case 'week':
      newExpiresAtDate = baseDate.add(const Duration(days: 7));
      break;
    case '1_month':
    case 'month':
      newExpiresAtDate = baseDate.add(const Duration(days: 30));
      break;
    case '3_months':
    case '3months':
      newExpiresAtDate = baseDate.add(const Duration(days: 90));
      break;
    case '1_year':
    case 'year':
      newExpiresAtDate = baseDate.add(const Duration(days: 365));
      break;
    default:
      newExpiresAtDate = baseDate.add(const Duration(days: 30));
  }

  String newExpiresAtStr = newExpiresAtDate.toIso8601String();

  final updateUrl = Uri.parse(
      'https://api.airtable.com/v0/$baseId/${Uri.encodeComponent(tableName)}/$recordId');

  final updateResponse = await http.patch(
    updateUrl,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'fields': {
        'ExpiresAt': newExpiresAtStr,
        'Duration': dur,
      }
    }),
  );

  if (updateResponse.statusCode == 200) {
    // تحديث تاريخ الانتهاء الجديد في App State
    String year = newExpiresAtDate.year.toString();
    String month = newExpiresAtDate.month.toString().padLeft(2, '0');
    String day = newExpiresAtDate.day.toString().padLeft(2, '0');
    FFAppState().licenseExpiryDateMSFS = "$year-$month-$day";

    return "Success";
  } else {
    return "Failed to extend license.";
  }
}
