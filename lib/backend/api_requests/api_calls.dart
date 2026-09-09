import 'dart:convert';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class GetMetarRawCall {
  static Future<ApiCallResponse> call({
    String? airportID = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getMetarRaw',
      apiUrl:
          'https://aviationweather.gov/api/data/metar?format=raw&ids=${airportID}',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetTafRawCall {
  static Future<ApiCallResponse> call({
    String? airportID = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getTafRaw',
      apiUrl:
          'https://aviationweather.gov/api/data/taf?format=raw&ids=${airportID}',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetSimBriefFlightCall {
  static Future<ApiCallResponse> call({
    String? userId = '682445',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'GetSimBriefFlight',
      apiUrl:
          'https://www.simbrief.com/api/xml.fetcher.php?userid=${userId}&json=1',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'userid': userId,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CheckLicenseCall {
  static Future<ApiCallResponse> call({
    String? licenseKey = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'CheckLicense',
      apiUrl: 'https://api.airtable.com/v0/appmz3issohHsNLRM/tblaXHKOQYOlzhaJu',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer patZuFHBTfOuzMmP7.b473d75321c56e35e5f7c0d76fcc330098903b08fabc3860400953058a89e39d',
      },
      params: {
        '{LicenseKey}': licenseKey,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? recordID(dynamic response) => (getJsonField(
        response,
        r'''$.records[:].id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static String? licenseKey(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.records[0].fields.LicenseKey''',
      ));
  static String? registeredDevice(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.records[:].fields.DeviceID''',
      ));
  static bool? isUsed(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.records[:].fields.IsUsed''',
      ));
}

class UpdateLicenseCall {
  static Future<ApiCallResponse> call({
    String? recordID = '',
    String? deviceID = '',
  }) async {
    final ffApiRequestBody = '''
{
  "fields": {
    "DeviceID": "[deviceID]",
    "IsUsed": true
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UpdateLicense',
      apiUrl:
          'https://api.airtable.com/v0/appmz3issohHsNLRM/tblaXHKOQYOlzhaJu/${recordID}',
      callType: ApiCallType.PATCH,
      headers: {
        'Authorization':
            'Bearer patZuFHBTfOuzMmP7.2b24961837ab92f06a0e05bc43b623be732cf368d6d7a07de78fedf6cc2b6577',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class AddLicenseCall {
  static Future<ApiCallResponse> call({
    String? newKey = '',
  }) async {
    final ffApiRequestBody = '''
{
  "fields": {
    "LicenseKey": "${escapeStringForJson(newKey)}"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'AddLicense',
      apiUrl: 'https://api.airtable.com/v0/appmz3issohHsNLRM/tblaXHKOQYOlzhaJu',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'Bearer patZuFHBTfOuzMmP7.b473d75321c56e35e5f7c0d76fcc330098903b08fabc3860400953058a89e39d',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetAirportInfoCall {
  static Future<ApiCallResponse> call({
    String? icao = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'GetAirportInfo',
      apiUrl: 'https://api.flightplandatabase.com/nav/airport/${icao}',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class XPayCall {
  static Future<ApiCallResponse> call() async {
    final ffApiRequestBody = '''
{
  "variable_amount_id": 1,
  "pay_using": "card",
  "amount": 349,
  "currency": "EGP",
  "billing_data": {
    "name": "Osama Nabil",
    "email": "test@example.com",
    "phone_number": "+201000000000"
  }
}
''';
    return ApiManager.instance.makeApiCall(
      callName: 'X Pay',
      apiUrl: 'https://staging.xpay.app/api/v1/payments/pay/variable-amount',
      callType: ApiCallType.POST,
      headers: {
        'x-api-key': 'sk_test_YJhso4GYo82X5Btybci7E5odPpPpmY7z',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class VatsimAPICall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'vatsim API',
      apiUrl: 'https://data.vatsim.net/v3/vatsim-data.json',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetElevationCall {
  static Future<ApiCallResponse> call({
    double? lat,
    double? lon,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'GetElevation',
      apiUrl: 'https://api.opentopodata.org/v1/srtm30m?locations=${lat},${lon}',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
