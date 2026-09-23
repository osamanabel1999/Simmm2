// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'dart:typed_data';

Future<double?> listenToXPlane(int row, int field) async {
  RawDatagramSocket? socket;
  try {
    // Bind to X-Plane's default sending port
    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 49000);

    double? value;
    // Listen for the incoming UDP packet
    await for (RawSocketEvent event
        in socket.timeout(const Duration(milliseconds: 500))) {
      if (event == RawSocketEvent.read) {
        Datagram? dg = socket.receive();
        if (dg != null && dg.data.length >= 5) {
          Uint8List data = dg.data;
          // Skip first 5 bytes (Header "DATA@")
          for (int i = 5; i < data.length; i += 36) {
            ByteData rowData = ByteData.view(data.buffer, i, 36);
            int currentRow = rowData.getUint32(0, Endian.little);

            if (currentRow == row) {
              // Each field is 4 bytes. Fields are 1-8.
              // Offset starts after the 4-byte row ID.
              int offset = 4 + ((field - 1) * 4);
              value = rowData.getFloat32(offset, Endian.little);
              break;
            }
          }
        }
        if (value != null) break;
      }
    }
    return value ?? 0.0;
  } catch (e) {
    return 0.0;
  } finally {
    socket?.close();
  }
}
