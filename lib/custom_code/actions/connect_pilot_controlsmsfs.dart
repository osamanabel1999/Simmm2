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

// 🔥 متغيرات معزولة تماماً لـ MSFS
Room? pilotRoomControls_msfs;
EventsListener<RoomEvent>? pilotListenerControls_msfs;

Future connectPilotControlsmsfs(
  String roomCode,

  // ==========================================
  // 1. MENU BUTTONS (8 Actions)
  // ==========================================
  Future<dynamic> Function()? menuPosition,
  Future<dynamic> Function()? menuPause,
  Future<dynamic> Function()? menuFreeze,
  Future<dynamic> Function()? menuPushback,
  Future<dynamic> Function()? menuMap,
  Future<dynamic> Function()? menuLoad,
  Future<dynamic> Function()? menuDoors,
  Future<dynamic> Function()? menuFailures,

  // ==========================================
  // 2. PUSHBACK BUTTONS (6 Actions)
  // ==========================================
  Future<dynamic> Function()? pbConnect,
  Future<dynamic> Function()? pbDisconnect,
  Future<dynamic> Function()? pbStop,
  Future<dynamic> Function()? pbTailLeft,
  Future<dynamic> Function()? pbStraight,
  Future<dynamic> Function()? pbTailRight,

  // ==========================================
  // 3. WEIGHTS BUTTONS (5 Actions)
  // ==========================================
  Future<dynamic> Function()? wtPilot,
  Future<dynamic> Function()? wtCoPilot,
  Future<dynamic> Function()? wtRearPax,
  Future<dynamic> Function()? wtBaggage,
  Future<dynamic> Function()? wtExtraCargo,

  // ==========================================
  // 4. DOORS BUTTONS (5 Actions)
  // ==========================================
  Future<dynamic> Function()? doorMain,
  Future<dynamic> Function()? doorCargo,
  Future<dynamic> Function()? doorService,
  Future<dynamic> Function()? doorAll,
  Future<dynamic> Function()? doorJetway,
) async {
  // 🔥 بيانات سيرفر MSFS الجديد لضمان مضاعفة الليمت
  const String apiKey = 'APIA87Lpk5cmUMP';
  const String apiSecret = 'aYWjjLKISVk663H7fYEBsx9cX69NTlg2er0oxtISsRD';
  const String livekitUrl =
      'wss://simulator-station-msfs-vb0uhblk.livekit.cloud';

  try {
    final cleanRoomCode = roomCode.trim();
    final jwt = JWT({
      'name':
          'Pilot_Listener_Controls_MSFS_${DateTime.now().millisecondsSinceEpoch}',
      'video': {
        'room': cleanRoomCode,
        'roomJoin': true,
        'canPublish': false, // ممنوع إرسال صوت/صورة
        'canSubscribe':
            false, // 🔥 الحماية: ممنوع استقبال أي صوت/صورة لتوفير الباقة
        'canPublishData': true, // مسموح بالداتا فقط
      },
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(hours: 4)))
              .millisecondsSinceEpoch ~/
          1000,
      'iss': apiKey,
      'sub': 'Pilot_Listener_Controls_MSFS',
    });

    final token = jwt.sign(SecretKey(apiSecret));

    if (pilotRoomControls_msfs != null) {
      await pilotRoomControls_msfs!.disconnect();
    }
    pilotListenerControls_msfs?.dispose();

    // 1. تعريف الغرفة بالشكل الصحيح برمجياً
    pilotRoomControls_msfs = Room();

    pilotListenerControls_msfs = pilotRoomControls_msfs!.createListener();

    pilotListenerControls_msfs!.on<DataReceivedEvent>((event) {
      if (event.topic == 'cmd' || event.topic == null) {
        try {
          final command = utf8.decode(event.data).trim();
          debugPrint("🎯 [رادار تحكم MSFS]: استلمت أمر: $command");

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
            else if (command == 'MENU_DOORS' && menuDoors != null)
              menuDoors();
            else if (command == 'MENU_FAILURES' && menuFailures != null)
              menuFailures();

            // --- 2. PUSHBACK ROUTER ---
            else if (command == 'PB_CONNECT' && pbConnect != null)
              pbConnect();
            else if (command == 'PB_DISCONNECT' && pbDisconnect != null)
              pbDisconnect();
            else if (command == 'PB_STOP' && pbStop != null)
              pbStop();
            else if (command == 'PB_TAIL_LEFT' && pbTailLeft != null)
              pbTailLeft();
            else if (command == 'PB_STRAIGHT' && pbStraight != null)
              pbStraight();
            else if (command == 'PB_TAIL_RIGHT' && pbTailRight != null)
              pbTailRight();

            // --- 3. WEIGHTS ROUTER ---
            else if (command == 'WT_PILOT' && wtPilot != null)
              wtPilot();
            else if (command == 'WT_COPILOT' && wtCoPilot != null)
              wtCoPilot();
            else if (command == 'WT_REAR_PAX' && wtRearPax != null)
              wtRearPax();
            else if (command == 'WT_BAGGAGE' && wtBaggage != null)
              wtBaggage();
            else if (command == 'WT_EXTRA_CARGO' && wtExtraCargo != null)
              wtExtraCargo();

            // --- 4. DOORS ROUTER ---
            else if (command == 'DOOR_MAIN' && doorMain != null)
              doorMain();
            else if (command == 'DOOR_CARGO' && doorCargo != null)
              doorCargo();
            else if (command == 'DOOR_SERVICE' && doorService != null)
              doorService();
            else if (command == 'DOOR_ALL' && doorAll != null)
              doorAll();
            else if (command == 'DOOR_JETWAY' && doorJetway != null)
              doorJetway();
          });
        } catch (e) {
          debugPrint("❌ [رادار تحكم MSFS]: خطأ في قراءة الأمر: $e");
        }
      }
    });

    // 2. 🔥 تطبيق حماية الباقة ومنع استقبال الصوت (autoSubscribe: false)
    await pilotRoomControls_msfs!.connect(
      livekitUrl,
      token,
      connectOptions: const ConnectOptions(
        autoSubscribe: false,
      ),
    );

    debugPrint(
        "✅ [رادار تحكم MSFS]: متصل داتا فقط ومستعد بغرفة: $cleanRoomCode");
  } catch (e) {
    debugPrint("❌ [رادار تحكم MSFS]: فشل الاتصال: $e");
  }
}
