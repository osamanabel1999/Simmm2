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

Future<String> getPlanTypeMSFS(String? licenseKey) async {
  // لو مفيش كود مبعوت، هيرجع Monthly Pass كقيمة افتراضية عشان ميسيبش الشاشة فاضية
  if (licenseKey == null || licenseKey.trim().isEmpty) {
    return "Monthly Pass";
  }

  const String token =
      'patZuFHBTfOuzMmP7.b473d75321c56e35e5f7c0d76fcc330098903b08fabc3860400953058a89e39d';
  const String baseId = 'appmz3issohHsNLRM';
  // استخدمنا نفس الـ tableId بتاع الكود اللي شغال معاك بالظبط
  const String tableId = 'tblse0E5FhASxuhmn';

  // تشفير سليم 100% لمعادلة البحث عشان ما يحصلش أي خطأ في الاتصال
  final String formula = '{LicenseKey}="${licenseKey.trim()}"';
  final url = Uri.parse(
      'https://api.airtable.com/v0/$baseId/$tableId?filterByFormula=${Uri.encodeComponent(formula)}');

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    // نفس شرط النجاح الموجود في الكود الشغال بتاعك
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      final List records = data['records'] ?? [];

      if (records.isNotEmpty) {
        // جلبنا الفيلدز واستخرجنا Duration
        final duration = records[0]['fields']['Duration'];

        if (duration == null) {
          return "Monthly Pass";
        }

        final clean = duration.toString().toLowerCase().trim();

        // فحص القيمة اللي راجعة
        if (clean == '1_month' ||
            clean.contains('month') ||
            clean == '30_days') {
          return "Monthly Pass";
        } else if (clean == '1_year' ||
            clean.contains('year') ||
            clean == '365_days') {
          return "Yearly Pass";
        } else if (clean == 'lifetime' || clean.contains('life')) {
          return "Lifetime Pass";
        } else {
          return "Monthly Pass";
        }
      } else {
        return "Monthly Pass";
      }
    } else {
      return "Monthly Pass";
    }
  } catch (e) {
    return "Monthly Pass";
  }
}
