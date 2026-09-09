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

Future<String?> checkXPlaneUserLicense(String? appUserId) async {
  if (appUserId == null || appUserId.trim().isEmpty) {
    return "INVALID_USER_ID";
  }

  const String token =
      'patZuFHBTfOuzMmP7.b473d75321c56e35e5f7c0d76fcc330098903b08fabc3860400953058a89e39d';
  const String baseId = 'appmz3issohHsNLRM';
  const String tableName = 'Table 1'; // جدول X-Plane الخاص بك كما هو

  final String cleanUserId = appUserId.trim();

  // البحث المباشر بـ AppUserID
  final String filterFormula = "{AppUserID} = '$cleanUserId'";
  final Uri url = Uri.parse(
      'https://api.airtable.com/v0/$baseId/${Uri.encodeComponent(tableName)}?filterByFormula=${Uri.encodeComponent(filterFormula)}');

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      final List records = data['records'] ?? [];

      if (records.isEmpty) {
        return "NOT_FOUND";
      }

      final fields = records.first['fields'] ?? {};
      final String rawLicenseKey =
          fields['LicenseKey']?.toString().trim() ?? '';

      if (rawLicenseKey.isNotEmpty) {
        return rawLicenseKey; // يرجع كود الرخصة القديم للمستخدم
      } else {
        return "NOT_FOUND";
      }
    } else {
      return "Error_${response.statusCode}";
    }
  } catch (e) {
    return "Error: $e";
  }
}
