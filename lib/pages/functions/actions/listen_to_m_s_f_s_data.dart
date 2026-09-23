// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:web_socket_channel/io.dart';

Future listenToMSFSData(String ipAddress) async {
  // التعديل هنا: استخدام المسار الصحيح للسيرفر اللي إنت مسطبه
  final url = 'ws://$ipAddress:2050/fsuipc/';
  final channel = IOWebSocketChannel.connect(url);

  channel.stream.listen((message) {
    try {
      final data = jsonDecode(message);

      // السيرفر ده بيبعت البيانات في العادة جوه "offsets" أو بشكل مباشر
      // هنا بنحدث الـ App State بناءً على القيم اللي راجعة
      FFAppState().update(() {
        // الارتفاع
        if (data['name'] == 'Altitude') {
          FFAppState().msfsaltitude = (data['value'] as num).toDouble();
        }

        // السرعة
        if (data['name'] == 'Airspeed') {
          FFAppState().msfsairspeed = (data['value'] as num).toDouble();
        }

        // الاتجاه
        if (data['name'] == 'Heading') {
          FFAppState().msfsheading = (data['value'] as num).toDouble();
        }

        // خط العرض
        if (data['name'] == 'Latitude') {
          FFAppState().msfslatitude = (data['value'] as num).toDouble();
        }

        // خط الطول
        if (data['name'] == 'Longitude') {
          FFAppState().msfslongitude = (data['value'] as num).toDouble();
        }
      });
    } catch (e) {
      print("JSON Parsing Error: $e");
    }
  }, onError: (error) {
    print("WebSocket Connection Error: $error");
  }, onDone: () {
    print("WebSocket Connection Closed");
  });
}
