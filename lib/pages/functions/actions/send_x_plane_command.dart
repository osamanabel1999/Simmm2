// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';

Future sendXPlaneCommand(String command, String ipAddress) async {
  // Your PC IP Address is now passed as a variable (ipAddress)
  int port = 49000;

  try {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
        .then((RawDatagramSocket socket) {
      // Data format: CMND + 0 byte + command string + 0 byte
      List<int> data =
          'CMND\x00'.codeUnits + command.codeUnits + '\x00'.codeUnits;

      socket.send(data, InternetAddress(ipAddress), port);
      socket.close();
      print('X-Plane Command Sent: $command');
    });
  } catch (e) {
    print('Error sending to X-Plane: $e');
  }
}
