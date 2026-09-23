// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'dart:typed_data';

Future setXPlaneDataRef(
  String dataRef,
  double value,
  String ipAddress, // تم إضافة متغير الـ IP هنا
) async {
  // تم حذف الـ IP الثابت واستخدام المتغير الممرر للفانكشن
  const int port = 49000;

  RawDatagramSocket? socket;
  try {
    // Initialize UDP socket
    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

    // Prepare DREF header (DREF + null byte)
    final Uint8List header = Uint8List.fromList([68, 82, 69, 70, 0]);

    // Convert value to 4-byte Float32 (Little Endian)
    final ByteData valueData = ByteData(4);
    valueData.setFloat32(0, value, Endian.little);

    // Prepare DataRef path and pad to 500 bytes as required by X-Plane
    final List<int> drefBytes = dataRef.codeUnits;
    final Uint8List drefBuffer = Uint8List(500);
    drefBuffer.setRange(0, drefBytes.length, drefBytes);

    // Assemble the complete packet
    final BytesBuilder packet = BytesBuilder();
    packet.add(header);
    packet.add(valueData.buffer.asUint8List());
    packet.add(drefBuffer);

    // Send packet to X-Plane
    socket.send(packet.toBytes(), InternetAddress(ipAddress), port);

    print('Data Sent Successfully to $ipAddress: $dataRef = $value');
  } catch (e) {
    print('Network Error: $e');
  } finally {
    socket?.close();
  }
}
