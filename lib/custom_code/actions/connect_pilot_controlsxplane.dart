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

Room? pilotRoomControls;
EventsListener<RoomEvent>? pilotListenerControls;

Future connectPilotControlsxplane(
  String roomCode,

  // ==========================================
  // 1. MENU BUTTONS (9 Actions)
  // ==========================================
  Future<dynamic> Function()? menuPosition,
  Future<dynamic> Function()? menuPause,
  Future<dynamic> Function()? menuFreeze,
  Future<dynamic> Function()? menuPushback,
  Future<dynamic> Function()? menuMap,
  Future<dynamic> Function()? menuLoad,
  Future<dynamic> Function()? menuWeather,
  Future<dynamic> Function()? menuFmc,
  Future<dynamic> Function()? menuFailures,

  // ==========================================
  // 2. PUSHBACK BUTTONS (6 Actions)
  // ==========================================
  Future<dynamic> Function()? pbView,
  Future<dynamic> Function()? pbPlan,
  Future<dynamic> Function()? pbConnect,
  Future<dynamic> Function()? pbReconnect,
  Future<dynamic> Function()? pbDisconnect,
  Future<dynamic> Function()? pbStop,
) async {
  const String apiKey = 'API5SxFp3ddtWz9';
  const String apiSecret = 'rj1SfmWRK0edm7XZ337xHSdeZEcXUWKdQhFtjBqMtxGB';
  const String livekitUrl = 'wss://simulator-station-ham7e1yr.livekit.cloud';

  try {
    final cleanRoomCode = roomCode.trim();
    final jwt = JWT({
      'name':
          'Pilot_Listener_Controls_${DateTime.now().millisecondsSinceEpoch}',
      'video': {
        'room': cleanRoomCode,
        'roomJoin': true,
        'canPublish': false, // ممنوع إرسال صوت/صورة
        'canSubscribe':
            false, // 🔥 تعديل الحماية: ممنوع استقبال أي صوت/صورة لتوفير الباقة
        'canPublishData': true, // مسموح بالداتا فقط
      },
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(hours: 4)))
              .millisecondsSinceEpoch ~/
          1000,
      'iss': apiKey,
      'sub': 'Pilot_Listener_Controls',
    });

    final token = jwt.sign(SecretKey(apiSecret));

    if (pilotRoomControls != null) {
      await pilotRoomControls!.disconnect();
    }
    pilotListenerControls?.dispose();

    // 🔥 تعديل الحماية السحري: إجبار الغرفة على الصمت التام واستقبال الداتا فقط
    pilotRoomControls = Room(
      roomOptions: const RoomOptions(
        autoSubscribe: false,
      ),
    );

    pilotListenerControls = pilotRoomControls!.createListener();

    pilotListenerControls!.on<DataReceivedEvent>((event) {
      if (event.topic == 'cmd' || event.topic == null) {
        try {
          final command = utf8.decode(event.data).trim();
          debugPrint("🎯 [رادار التحكم]: استلمت أمر: $command");

          WidgetsBinding.instance.addPostFrameCallback((_) {
            // --- 1. MENU ROUTER ---
            if (command == 'MENU_POSITION' && menuPosition != null)
              menuPosition();
            else if (command == 'MENU_PAUSE' && menuPause != null)
              menuPause();
            else if (command == 'MENU_FREEZE' && menuFreeze != null)
              menuFreeze();
            else if (command == 'MENU_PUSHBACK' && menuPushback != null)
              menuPushback();
            else if (command == 'MENU_MAP' && menuMap != null)
              menuMap();
            else if (command == 'MENU_LOAD' && menuLoad != null)
              menuLoad();
            else if (command == 'MENU_WEATHER' && menuWeather != null)
              menuWeather();
            else if (command == 'MENU_FMC' && menuFmc != null)
              menuFmc();
            else if (command == 'MENU_FAILURES' && menuFailures != null)
              menuFailures();

            // --- 2. PUSHBACK ROUTER ---
            else if (command == 'PB_VIEW' && pbView != null)
              pbView();
            else if (command == 'PB_PLAN' && pbPlan != null)
              pbPlan();
            else if (command == 'PB_CONNECT' && pbConnect != null)
              pbConnect();
            else if (command == 'PB_RECONNECT' && pbReconnect != null)
              pbReconnect();
            else if (command == 'PB_DISCONNECT' && pbDisconnect != null)
              pbDisconnect();
            else if (command == 'PB_STOP' && pbStop != null) pbStop();
          });
        } catch (e) {
          debugPrint("❌ [رادار التحكم]: خطأ في قراءة الأمر: $e");
        }
      }
    });

    await pilotRoomControls!.connect(livekitUrl, token);
    debugPrint("✅ [رادار التحكم]: متصل داتا فقط ومستعد بغرفة: $cleanRoomCode");
  } catch (e) {
    debugPrint("❌ [رادار التحكم]: فشل الاتصال: $e");
  }
}
