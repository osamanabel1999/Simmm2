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

Future<dynamic> getSubscriptionDetailsFromList(String? simulatorType) async {
  List<String> entitlementIds = [];

  if (simulatorType == 'XPLANE') {
    entitlementIds = [
      'simulator_station_xplane',
      'simulator_station_msfs_xplane',
    ];
  } else if (simulatorType == 'MSFS') {
    entitlementIds = [
      'simulator_station_pro',
      'simulator_station_msfs_xplane',
    ];
  } else {
    entitlementIds = [
      'simulator_station_msfs_xplane',
      'simulator_station_pro',
      'simulator_station_xplane',
    ];
  }

  try {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();

    for (String entitlementId in entitlementIds) {
      EntitlementInfo? entitlement =
          customerInfo.entitlements.all[entitlementId];

      if (entitlement != null && entitlement.isActive) {
        String planType = 'Monthly';
        String simTitle = 'X-PLANE';
        String priceText = '\$0.00';
        String formattedDate = 'Lifetime';

        // 1. تحديد اسم المحاكي بناءً على الـ Entitlement
        if (entitlementId == 'simulator_station_msfs_xplane') {
          simTitle = 'MSFS & X-PLANE';
        } else if (entitlementId == 'simulator_station_pro') {
          simTitle = 'MSFS 2020/2024';
        } else {
          simTitle = 'X-PLANE';
        }

        // 2. استخراج السعر الحقيقي للباقة من المتاجر
        String productId = entitlement.productIdentifier;
        if (productId.isNotEmpty) {
          try {
            List<StoreProduct> products =
                await Purchases.getProducts([productId]);
            if (products.isNotEmpty) {
              priceText = products.first
                  .priceString; // يرجع السعر مع عملة المستخدم (EGP 149.99)
            }
          } catch (e) {
            debugPrint('Error fetching product price for $productId: $e');
          }
        }

        // 3. تحديد نوع الخطة
        String lowerProductId = productId.toLowerCase();
        if (lowerProductId.contains('yearly') ||
            lowerProductId.contains('annual') ||
            lowerProductId.contains('1y')) {
          planType = 'Yearly Pass';
        } else if (lowerProductId.contains('lifetime') ||
            entitlement.expirationDate == null) {
          planType = 'Lifetime Pass';
        } else {
          planType = 'Monthly Pass';
        }

        // 4. معالجة وتنسيق تاريخ الانتهاء بأمان بدون Crashes
        if (entitlement.expirationDate != null) {
          try {
            dynamic expDate = entitlement.expirationDate;
            DateTime? parsedDate;

            if (expDate is DateTime) {
              parsedDate = expDate;
            } else if (expDate is String && expDate.isNotEmpty) {
              parsedDate = DateTime.tryParse(expDate);
            }

            if (parsedDate != null) {
              DateTime localDate = parsedDate.toLocal();
              formattedDate =
                  "${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}";
            }
          } catch (e) {
            debugPrint('Error parsing date: $e');
          }
        } else {
          planType = 'Lifetime Pass';
          formattedDate = 'Lifetime';
        }

        return {
          'is_active': true,
          'status': 'ACTIVE',
          'simulator_type': simTitle,
          'plan_type': planType,
          'expiration_date': formattedDate,
          'price_text': priceText,
        };
      }
    }
  } catch (e) {
    debugPrint('Error checking entitlement list: $e');
  }

  return {
    'is_active': false,
    'status': 'INACTIVE',
    'simulator_type': 'NO SIMULATOR',
    'plan_type': 'No Active Plan',
    'expiration_date': 'Not Active',
    'price_text': '\$0.00',
  };
}
