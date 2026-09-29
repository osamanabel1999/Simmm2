// Automatic FlutterFlow imports
import '/flutter_flow/ff_builtin_enums.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:livekit_client/livekit_client.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:convert';

Room? pilotRoomxplane;
EventsListener<RoomEvent>? pilotListenerxplane;

Future connectPilotListenerxplane(
  String roomCode,
  Future<dynamic> Function()? onTestCommand,
) async {
  const String apiKey = 'API5SxFp3ddtWz9';
  const String apiSecret = 'rj1SfmWRK0edm7XZ337xHSdeZEcXUWKdQhFtjBqMtxGB';
  const String livekitUrl = 'wss://simulator-station-ham7e1yr.livekit.cloud';

  try {
    final cleanRoomCode = roomCode.trim();

    final jwt = JWT({
      'name': 'Pilot_Listener_${DateTime.now().millisecondsSinceEpoch}',
      'video': {
        'room': cleanRoomCode,
        'roomJoin': true,
        'canPublish': false,
        'canSubscribe': true,
        'canPublishData': true, // إذن استقبال البيانات اللي كان ناقص
      },
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(hours: 4)))
              .millisecondsSinceEpoch ~/
          1000,
      'iss': apiKey,
      'sub': 'Pilot_Listener',
    });

    final token = jwt.sign(SecretKey(apiSecret));

    if (pilotRoomxplane != null) {
      await pilotRoomxplane!.disconnect();
    }
    pilotListenerxplane?.dispose();

    pilotRoomxplane = Room();
    pilotListenerxplane = pilotRoomxplane!.createListener();

    pilotListenerxplane!.on<DataReceivedEvent>((event) {
      if (event.topic == 'cmd') {
        try {
          final command = utf8.decode(event.data);

          FFAppState().update(() {
            FFAppState().receivedCommand = command;
          });

          if (command == 'TEST') {
            if (onTestCommand != null) {
              // إجبار ظهور السناك بار على الشاشة
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onTestCommand();
              });
            }
          }
        } catch (e) {}
      }
    });

    await pilotRoomxplane!.connect(livekitUrl, token);
  } catch (e) {}
}
