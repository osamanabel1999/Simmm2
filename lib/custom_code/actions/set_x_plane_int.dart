// Automatic FlutterFlow imports
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
import 'dart:io';
import 'dart:typed_data';

Future setXPlaneInt(
  String dataRef,
  int value,
) async {
  const String ipAddress = '192.168.1.87'; // الـ IP بتاع جهازك
  const int port = 49000;

  RawDatagramSocket? socket;
  try {
    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

    // 1. Header (5 bytes)
    final Uint8List header = Uint8List.fromList([68, 82, 69, 70, 0]); // "DREF0"

    // 2. القيمة Integer (4 Bytes)
    // بنستخدم setInt32 عشان نبعت رقم صحيح صريح 32-بت
    final ByteData valueData = ByteData(4);
    valueData.setInt32(0, value, Endian.little);

    // 3. التكملة لـ 504 بايت (Padding)
    // الحسبة: 5 (header) + 4 (value) + 495 (padding) = 504 بايت
    final List<int> drefBytes = dataRef.codeUnits;
    final Uint8List drefBuffer = Uint8List(495);
    drefBuffer.setRange(0, drefBytes.length, drefBytes);

    // 4. تجميع الرسالة
    final BytesBuilder packet = BytesBuilder();
    packet.add(header);
    packet.add(valueData.buffer.asUint8List());
    packet.add(drefBuffer);

    socket.send(packet.toBytes(), InternetAddress(ipAddress), port);

    print('Int Sent: $dataRef = $value');
  } catch (e) {
    print('UDP Error: $e');
  } finally {
    socket?.close();
  }
}
