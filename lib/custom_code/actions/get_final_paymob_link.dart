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

Future<String?> getFinalPaymobLink() async {
  try {
    // 1. Auth Step
    final authResponse = await http.post(
      Uri.parse('https://accept.paymob.com/api/auth/tokens'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "api_key":
            "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRFeU9UQXlNaXdpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS52djRCT1VsTFlfTWU2WXlsaGNTUHljOUozRGFLb2R2ejVwcUpsUTBib2RJV3N4ajVOb212bk9UNl9FWnBhYTl6NmZMZllWeDhSYWR6TDRiUTdERV9wdw=="
      }),
    );

    if (authResponse.statusCode != 201)
      return "Error in Auth: ${authResponse.body}";
    final String authToken = jsonDecode(authResponse.body)['token'];

    // 2. Order Step
    final orderResponse = await http.post(
      Uri.parse('https://accept.paymob.com/api/ecommerce/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "auth_token": authToken,
        "delivery_needed": false,
        "amount_cents": 34900,
        "currency": "EGP",
        "items": []
      }),
    );

    if (orderResponse.statusCode != 201)
      return "Error in Order: ${orderResponse.body}";
    final int orderId = jsonDecode(orderResponse.body)['id'];

    // 3. Payment Key Step
    final keyResponse = await http.post(
      Uri.parse('https://accept.paymob.com/api/acceptance/payment_keys'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "auth_token": authToken,
        "amount_cents": 34900,
        "expiration": 3600,
        "order_id": orderId.toString(),
        "billing_data": {
          "apartment": "NA",
          "email": "pilot@example.com",
          "floor": "NA",
          "first_name": "Aviation",
          "street": "NA",
          "building": "NA",
          "phone_number": "01000000000",
          "shipping_method": "NA",
          "postal_code": "NA",
          "city": "Cairo",
          "country": "EG",
          "last_name": "User",
          "state": "NA"
        },
        "currency": "EGP",
        "integration_id": 5499966
      }),
    );

    if (keyResponse.statusCode != 201)
      return "Error in PaymentKey: ${keyResponse.body}";
    final String paymentToken = jsonDecode(keyResponse.body)['token'];

    // 4. Final Link
    return "https://accept.paymob.com/api/acceptance/iframes/1003941?payment_token=$paymentToken";
  } catch (e) {
    return "System Error: $e";
  }
}
