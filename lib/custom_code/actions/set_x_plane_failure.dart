// Automatic FlutterFlow imports
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'dart:typed_data';

Future setXPlaneFailure(
  String dataRef,
  double value,
  int delaySeconds,
  String ipAddress, // تم إضافة المتغير هنا
) async {
  // تم إزالة السطر الثابت للـ IP والاعتماد على المتغير الممرر للدالة
  const int port = 49000;

  // If user provided a delay, wait before execution
  if (delaySeconds > 0) {
    await Future.delayed(Duration(seconds: delaySeconds));
  }

  RawDatagramSocket? socket;
  try {
    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

    final Uint8List header = Uint8List.fromList([68, 82, 69, 70, 0]);
    final ByteData valueData = ByteData(4);
    valueData.setFloat32(0, value, Endian.little);

    final List<int> drefBytes = dataRef.codeUnits;
    final Uint8List drefBuffer = Uint8List(500);
    drefBuffer.setRange(0, drefBytes.length, drefBytes);

    final BytesBuilder packet = BytesBuilder();
    packet.add(header);
    packet.add(valueData.buffer.asUint8List());
    packet.add(drefBuffer);

    socket.send(packet.toBytes(), InternetAddress(ipAddress), port);
    print('Failure Triggered: $dataRef after $delaySeconds seconds');
  } catch (e) {
    print('Connection Error: $e');
  } finally {
    socket?.close();
  }
}
