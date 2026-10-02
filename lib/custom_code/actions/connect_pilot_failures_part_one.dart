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

Future connectPilotFailuresPartOne(
  String roomCode,
  // ==========================================
  // 1. ENGINE FAILURES (18 Actions)
  // ==========================================
  Future<dynamic> Function()? eng1Flameout,
  Future<dynamic> Function()? eng2Flameout,
  Future<dynamic> Function()? eng1Fire,
  Future<dynamic> Function()? eng2Fire,
  Future<dynamic> Function()? eng1Fail,
  Future<dynamic> Function()? eng2Fail,
  Future<dynamic> Function()? eng1OilTemp,
  Future<dynamic> Function()? eng2OilTemp,
  Future<dynamic> Function()? eng1OilPress,
  Future<dynamic> Function()? eng2OilPress,
  Future<dynamic> Function()? reverserLock1,
  Future<dynamic> Function()? reverserLock2,
  Future<dynamic> Function()? reverserDeploy1,
  Future<dynamic> Function()? reverserDeploy2,
  Future<dynamic> Function()? afterBurner1,
  Future<dynamic> Function()? afterBurner2,
  Future<dynamic> Function()? compressorStall1,
  Future<dynamic> Function()? compressorStall2,

  // ==========================================
  // 2. APU FAILURES (3 Actions)
  // ==========================================
  Future<dynamic> Function()? apuFail,
  Future<dynamic> Function()? apuFire,
  Future<dynamic> Function()? rapidDepres,

  // ==========================================
  // 3. BLEED FAILURES (3 Actions)
  // ==========================================
  Future<dynamic> Function()? lBleedLeak,
  Future<dynamic> Function()? rBleedLeak,
  Future<dynamic> Function()? apuBleedFault,

  // ==========================================
  // 4. ELEC FAILURES (10 Actions)
  // ==========================================
  Future<dynamic> Function()? bat1,
  Future<dynamic> Function()? bat2,
  Future<dynamic> Function()? acBus1,
  Future<dynamic> Function()? acBus2,
  Future<dynamic> Function()? lEngGen,
  Future<dynamic> Function()? rEngGen,
  Future<dynamic> Function()? bat1LowVolt,
  Future<dynamic> Function()? bat2LowVolt,
  Future<dynamic> Function()? bat1HighVolt,
  Future<dynamic> Function()? bat2HighVolt,

  // ==========================================
  // 5. FUEL FAILURES (15 Actions)
  // ==========================================
  Future<dynamic> Function()? engFuelPump1,
  Future<dynamic> Function()? engFuelPump2,
  Future<dynamic> Function()? fuelFlowInd1,
  Future<dynamic> Function()? fuelFlowInd2,
  Future<dynamic> Function()? fuelPressInd1,
  Future<dynamic> Function()? fuelPressInd2,
  Future<dynamic> Function()? fuelVentBlock1,
  Future<dynamic> Function()? fuelVentBlock2,
  Future<dynamic> Function()? fuelVentBlock3,
  Future<dynamic> Function()? fuelVentBlock4,
  Future<dynamic> Function()? fuelVentBlock5,
  Future<dynamic> Function()? fuelCapLeftOff,
  Future<dynamic> Function()? waterInFuel,
  Future<dynamic> Function()? wrongFuelGas,
  Future<dynamic> Function()? fuelQuantitySensor,

  // ==========================================
  // 6. HYDRAULIC FAILURES (7 Actions)
  // ==========================================
  Future<dynamic> Function()? engHydPump1,
  Future<dynamic> Function()? engHydPump2,
  Future<dynamic> Function()? leakHydSys1,
  Future<dynamic> Function()? leakHydSys2,
  Future<dynamic> Function()? overpressHydSys1,
  Future<dynamic> Function()? overpressHydSys2,
  Future<dynamic> Function()? elecPumpFail,
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
        'canPublish': false, // منع الإرسال
        'canSubscribe': false, // 🔥 منع الاستقبال (توفير الباقة وإلغاء الصوت)
        'canPublishData': true,
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

    // 🔥 إجبار الغرفة على الصمت التام واستقبال البيانات فقط
    pilotRoomxplane = Room(
      roomOptions: const RoomOptions(
        autoSubscribe: false,
      ),
    );

    pilotListenerxplane = pilotRoomxplane!.createListener();

    pilotListenerxplane!.on<DataReceivedEvent>((event) {
      if (event.topic == 'cmd' || event.topic == null) {
        try {
          final command = utf8.decode(event.data).trim();
          debugPrint("🎯 [رادار الطيار]: استلمت عطل: $command");

          WidgetsBinding.instance.addPostFrameCallback((_) {
            // --- 1. ENGINE ROUTER ---
            if (command == 'ENG1_FLAMEOUT' && eng1Flameout != null)
              eng1Flameout();
            else if (command == 'ENG2_FLAMEOUT' && eng2Flameout != null)
              eng2Flameout();
            else if (command == 'ENG1_FIRE' && eng1Fire != null)
              eng1Fire();
            else if (command == 'ENG2_FIRE' && eng2Fire != null)
              eng2Fire();
            else if (command == 'ENG1_FAIL' && eng1Fail != null)
              eng1Fail();
            else if (command == 'ENG2_FAIL' && eng2Fail != null)
              eng2Fail();
            else if (command == 'ENG1_OIL_TEMP' && eng1OilTemp != null)
              eng1OilTemp();
            else if (command == 'ENG2_OIL_TEMP' && eng2OilTemp != null)
              eng2OilTemp();
            else if (command == 'ENG1_OIL_PRESS' && eng1OilPress != null)
              eng1OilPress();
            else if (command == 'ENG2_OIL_PRESS' && eng2OilPress != null)
              eng2OilPress();
            else if (command == 'REV_LOCK_1' && reverserLock1 != null)
              reverserLock1();
            else if (command == 'REV_LOCK_2' && reverserLock2 != null)
              reverserLock2();
            else if (command == 'REV_DEP_1' && reverserDeploy1 != null)
              reverserDeploy1();
            else if (command == 'REV_DEP_2' && reverserDeploy2 != null)
              reverserDeploy2();
            else if (command == 'AFTER_BURNER_1' && afterBurner1 != null)
              afterBurner1();
            else if (command == 'AFTER_BURNER_2' && afterBurner2 != null)
              afterBurner2();
            else if (command == 'COMP_STALL_1' && compressorStall1 != null)
              compressorStall1();
            else if (command == 'COMP_STALL_2' && compressorStall2 != null)
              compressorStall2();

            // --- 2. APU ROUTER ---
            else if (command == 'APU_FAIL' && apuFail != null)
              apuFail();
            else if (command == 'APU_FIRE' && apuFire != null)
              apuFire();
            else if (command == 'RAPID_DEPRES' && rapidDepres != null)
              rapidDepres();

            // --- 3. BLEED ROUTER ---
            else if (command == 'L_BLEED_LEAK' && lBleedLeak != null)
              lBleedLeak();
            else if (command == 'R_BLEED_LEAK' && rBleedLeak != null)
              rBleedLeak();
            else if (command == 'APU_BLEED_FAULT' && apuBleedFault != null)
              apuBleedFault();

            // --- 4. ELEC ROUTER ---
            else if (command == 'BAT_1' && bat1 != null)
              bat1();
            else if (command == 'BAT_2' && bat2 != null)
              bat2();
            else if (command == 'AC_BUS_1' && acBus1 != null)
              acBus1();
            else if (command == 'AC_BUS_2' && acBus2 != null)
              acBus2();
            else if (command == 'L_ENG_GEN' && lEngGen != null)
              lEngGen();
            else if (command == 'R_ENG_GEN' && rEngGen != null)
              rEngGen();
            else if (command == 'BAT_1_LOW_VOLT' && bat1LowVolt != null)
              bat1LowVolt();
            else if (command == 'BAT_2_LOW_VOLT' && bat2LowVolt != null)
              bat2LowVolt();
            else if (command == 'BAT_1_HIGH_VOLT' && bat1HighVolt != null)
              bat1HighVolt();
            else if (command == 'BAT_2_HIGH_VOLT' && bat2HighVolt != null)
              bat2HighVolt();

            // --- 5. FUEL ROUTER ---
            else if (command == 'ENG_FUEL_PUMP_1' && engFuelPump1 != null)
              engFuelPump1();
            else if (command == 'ENG_FUEL_PUMP_2' && engFuelPump2 != null)
              engFuelPump2();
            else if (command == 'FUEL_FLOW_IND_1' && fuelFlowInd1 != null)
              fuelFlowInd1();
            else if (command == 'FUEL_FLOW_IND_2' && fuelFlowInd2 != null)
              fuelFlowInd2();
            else if (command == 'FUEL_PRESS_IND_1' && fuelPressInd1 != null)
              fuelPressInd1();
            else if (command == 'FUEL_PRESS_IND_2' && fuelPressInd2 != null)
              fuelPressInd2();
            else if (command == 'FUEL_VENT_BLK_1' && fuelVentBlock1 != null)
              fuelVentBlock1();
            else if (command == 'FUEL_VENT_BLK_2' && fuelVentBlock2 != null)
              fuelVentBlock2();
            else if (command == 'FUEL_VENT_BLK_3' && fuelVentBlock3 != null)
              fuelVentBlock3();
            else if (command == 'FUEL_VENT_BLK_4' && fuelVentBlock4 != null)
              fuelVentBlock4();
            else if (command == 'FUEL_VENT_BLK_5' && fuelVentBlock5 != null)
              fuelVentBlock5();
            else if (command == 'FUEL_CAP_LEFT_OFF' && fuelCapLeftOff != null)
              fuelCapLeftOff();
            else if (command == 'WATER_IN_FUEL' && waterInFuel != null)
              waterInFuel();
            else if (command == 'WRONG_FUEL_GAS' && wrongFuelGas != null)
              wrongFuelGas();
            else if (command == 'FUEL_QTY_SENSOR' && fuelQuantitySensor != null)
              fuelQuantitySensor();

            // --- 6. HYDRAULIC ROUTER ---
            else if (command == 'ENG_HYD_PUMP_1' && engHydPump1 != null)
              engHydPump1();
            else if (command == 'ENG_HYD_PUMP_2' && engHydPump2 != null)
              engHydPump2();
            else if (command == 'LEAK_HYD_SYS_1' && leakHydSys1 != null)
              leakHydSys1();
            else if (command == 'LEAK_HYD_SYS_2' && leakHydSys2 != null)
              leakHydSys2();
            else if (command == 'OVERPRESS_HYD_1' && overpressHydSys1 != null)
              overpressHydSys1();
            else if (command == 'OVERPRESS_HYD_2' && overpressHydSys2 != null)
              overpressHydSys2();
            else if (command == 'ELEC_PUMP_FAIL' && elecPumpFail != null)
              elecPumpFail();
          });
        } catch (e) {
          debugPrint("❌ [رادار الطيار]: خطأ في قراءة العطل: $e");
        }
      }
    });

    await pilotRoomxplane!.connect(livekitUrl, token);
    debugPrint("✅ [رادار الطيار]: متصل ومستعد بغرفة: $cleanRoomCode");
  } catch (e) {
    debugPrint("❌ [رادار الطيار]: فشل الاتصال: $e");
  }
}
