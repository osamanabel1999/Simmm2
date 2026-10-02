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

Room? pilotRoomPartTwo;
EventsListener<RoomEvent>? pilotListenerPartTwo;

Future connectPilotFailuresPartTwo(
  String roomCode,
  // ==========================================
  // 1. AUTO FLT (3 Actions)
  // ==========================================
  Future<dynamic> Function()? yawDamper,
  Future<dynamic> Function()? autoPilotComputer,
  Future<dynamic> Function()? autoThrottle,

  // ==========================================
  // 2. FLT CTRL (7 Actions)
  // ==========================================
  Future<dynamic> Function()? flapActuatorSystem,
  Future<dynamic> Function()? slats,
  Future<dynamic> Function()? leftFlap,
  Future<dynamic> Function()? rightFlap,
  Future<dynamic> Function()? rudderTrimActuator,
  Future<dynamic> Function()? elevatorTrimActuator,
  Future<dynamic> Function()? aileronTrimActuator,

  // ==========================================
  // 3. LDG GEAR (10 Actions)
  // ==========================================
  Future<dynamic> Function()? noseGearJam,
  Future<dynamic> Function()? leftMlgJam,
  Future<dynamic> Function()? rightMlgJam,
  Future<dynamic> Function()? gearActuatorSystem,
  Future<dynamic> Function()? gearIndicatorSystem,
  Future<dynamic> Function()? leftBrake,
  Future<dynamic> Function()? rightBrake,
  Future<dynamic> Function()? leftMlgTire,
  Future<dynamic> Function()? rightMlgTire,
  Future<dynamic> Function()? noseWheelTire,

  // ==========================================
  // 4. NAVIGATION (14 Actions)
  // ==========================================
  Future<dynamic> Function()? com1,
  Future<dynamic> Function()? com2,
  Future<dynamic> Function()? nav1,
  Future<dynamic> Function()? nav2,
  Future<dynamic> Function()? adf1,
  Future<dynamic> Function()? adf2,
  Future<dynamic> Function()? gps1,
  Future<dynamic> Function()? gps2,
  Future<dynamic> Function()? dme,
  Future<dynamic> Function()? locAntennae,
  Future<dynamic> Function()? gsAntennae,
  Future<dynamic> Function()? waasGpReceiver,
  Future<dynamic> Function()? markerBeacons,
  Future<dynamic> Function()? transporter,

  // ==========================================
  // 5. WORLD (15 Actions)
  // ==========================================
  Future<dynamic> Function()? birdStrike,
  Future<dynamic> Function()? microburst,
  Future<dynamic> Function()? smokeInCockpit,
  Future<dynamic> Function()? runwayLights,
  Future<dynamic> Function()? papiLights,
  Future<dynamic> Function()? brownOut,
  Future<dynamic> Function()? instrumentsLights,
  Future<dynamic> Function()? floodLights,
  Future<dynamic> Function()? taxiLights1,
  Future<dynamic> Function()? ldgLights,
  Future<dynamic> Function()? taxiLights2,
  Future<dynamic> Function()? strobeLights,
  Future<dynamic> Function()? beaconLights,
  Future<dynamic> Function()? navigationLights,
  Future<dynamic> Function()? doorStillOpen,

  // ==========================================
  // 6. GLOBAL (1 Action)
  // ==========================================
  Future<dynamic> Function()? fixAll,

  // ==========================================
  // 7. MENU BUTTONS (11 Actions)
  // ==========================================
  Future<dynamic> Function()? menuEngine,
  Future<dynamic> Function()? menuApu,
  Future<dynamic> Function()? menuBleed,
  Future<dynamic> Function()? menuElec,
  Future<dynamic> Function()? menuFuel,
  Future<dynamic> Function()? menuHydraulic,
  Future<dynamic> Function()? menuAutoFlt,
  Future<dynamic> Function()? menuFltCtrl,
  Future<dynamic> Function()? menuLdgGear,
  Future<dynamic> Function()? menuNavigation,
  Future<dynamic> Function()? menuWorld,
) async {
  const String apiKey = 'API5SxFp3ddtWz9';
  const String apiSecret = 'rj1SfmWRK0edm7XZ337xHSdeZEcXUWKdQhFtjBqMtxGB';
  const String livekitUrl = 'wss://simulator-station-ham7e1yr.livekit.cloud';

  try {
    final cleanRoomCode = roomCode.trim();
    final jwt = JWT({
      'name': 'Pilot_Listener_P2_${DateTime.now().millisecondsSinceEpoch}',
      'video': {
        'room': cleanRoomCode,
        'roomJoin': true,
        'canPublish': false, // منع الإرسال
        'canSubscribe': false, // 🔥 منع استقبال الصوت والصورة (حماية الباقة)
        'canPublishData': true,
      },
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(hours: 4)))
              .millisecondsSinceEpoch ~/
          1000,
      'iss': apiKey,
      'sub': 'Pilot_Listener_P2',
    });

    final token = jwt.sign(SecretKey(apiSecret));

    if (pilotRoomPartTwo != null) {
      await pilotRoomPartTwo!.disconnect();
    }
    pilotListenerPartTwo?.dispose();

    // 1. تعريف الغرفة برمجياً بدون خطأ الباراميتر
    pilotRoomPartTwo = Room();

    pilotListenerPartTwo = pilotRoomPartTwo!.createListener();

    pilotListenerPartTwo!.on<DataReceivedEvent>((event) {
      if (event.topic == 'cmd' || event.topic == null) {
        try {
          final command = utf8.decode(event.data).trim();
          debugPrint("🎯 [رادار الطيار 2]: استلمت أمر: $command");

          WidgetsBinding.instance.addPostFrameCallback((_) {
            // --- 1. AUTO FLT ---
            if (command == 'YAW_DAMPER' && yawDamper != null)
              yawDamper();
            else if (command == 'AUTO_PILOT_COMPUTER' &&
                autoPilotComputer != null)
              autoPilotComputer();
            else if (command == 'AUTO_THROTTLE' && autoThrottle != null)
              autoThrottle();

            // --- 2. FLT CTRL ---
            else if (command == 'FLAP_ACTUATOR_SYSTEM' &&
                flapActuatorSystem != null)
              flapActuatorSystem();
            else if (command == 'SLATS' && slats != null)
              slats();
            else if (command == 'LEFT_FLAP' && leftFlap != null)
              leftFlap();
            else if (command == 'RIGHT_FLAP' && rightFlap != null)
              rightFlap();
            else if (command == 'RUDDER_TRIM_ACTUATOR' &&
                rudderTrimActuator != null)
              rudderTrimActuator();
            else if (command == 'ELEVATOR_TRIM_ACTUATOR' &&
                elevatorTrimActuator != null)
              elevatorTrimActuator();
            else if (command == 'AILERON_TRIM_ACTUATOR' &&
                aileronTrimActuator != null)
              aileronTrimActuator();

            // --- 3. LDG GEAR ---
            else if (command == 'NOSE_GEAR_JAM' && noseGearJam != null)
              noseGearJam();
            else if (command == 'LEFT_MLG_JAM' && leftMlgJam != null)
              leftMlgJam();
            else if (command == 'RIGHT_MLG_JAM' && rightMlgJam != null)
              rightMlgJam();
            else if (command == 'GEAR_ACTUATOR_SYSTEM' &&
                gearActuatorSystem != null)
              gearActuatorSystem();
            else if (command == 'GEAR_INDICATOR_SYSTEM' &&
                gearIndicatorSystem != null)
              gearIndicatorSystem();
            else if (command == 'LEFT_BRAKE' && leftBrake != null)
              leftBrake();
            else if (command == 'RIGHT_BRAKE' && rightBrake != null)
              rightBrake();
            else if (command == 'LEFT_MLG_TIRE' && leftMlgTire != null)
              leftMlgTire();
            else if (command == 'RIGHT_MLG_TIRE' && rightMlgTire != null)
              rightMlgTire();
            else if (command == 'NOSE_WHEEL_TIRE' && noseWheelTire != null)
              noseWheelTire();

            // --- 4. NAVIGATION ---
            else if (command == 'COM_1' && com1 != null)
              com1();
            else if (command == 'COM_2' && com2 != null)
              com2();
            else if (command == 'NAV_1' && nav1 != null)
              nav1();
            else if (command == 'NAV_2' && nav2 != null)
              nav2();
            else if (command == 'ADF_1' && adf1 != null)
              adf1();
            else if (command == 'ADF_2' && adf2 != null)
              adf2();
            else if (command == 'GPS_1' && gps1 != null)
              gps1();
            else if (command == 'GPS_2' && gps2 != null)
              gps2();
            else if (command == 'DME' && dme != null)
              dme();
            else if (command == 'LOC_ANTENNAE' && locAntennae != null)
              locAntennae();
            else if (command == 'GS_ANTENNAE' && gsAntennae != null)
              gsAntennae();
            else if (command == 'WAAS_GP_RECEIVER' && waasGpReceiver != null)
              waasGpReceiver();
            else if (command == 'MARKER_BEACONS' && markerBeacons != null)
              markerBeacons();
            else if (command == 'TRANSPORTER' && transporter != null)
              transporter();

            // --- 5. WORLD ---
            else if (command == 'BIRD_STRIKE' && birdStrike != null)
              birdStrike();
            else if (command == 'MICROBURST' && microburst != null)
              microburst();
            else if (command == 'SMOKE_IN_COCKPIT' && smokeInCockpit != null)
              smokeInCockpit();
            else if (command == 'RUNWAY_LIGHTS' && runwayLights != null)
              runwayLights();
            else if (command == 'PAPI_LIGHTS' && papiLights != null)
              papiLights();
            else if (command == 'BROWN_OUT' && brownOut != null)
              brownOut();
            else if (command == 'INSTRUMENTS_LIGHTS' &&
                instrumentsLights != null)
              instrumentsLights();
            else if (command == 'FLOOD_LIGHTS' && floodLights != null)
              floodLights();
            else if (command == 'TAXI_LIGHTS_1' && taxiLights1 != null)
              taxiLights1();
            else if (command == 'LDG_LIGHTS' && ldgLights != null)
              ldgLights();
            else if (command == 'TAXI_LIGHTS_2' && taxiLights2 != null)
              taxiLights2();
            else if (command == 'STROBE_LIGHTS' && strobeLights != null)
              strobeLights();
            else if (command == 'BEACON_LIGHTS' && beaconLights != null)
              beaconLights();
            else if (command == 'NAVIGATION_LIGHTS' && navigationLights != null)
              navigationLights();
            else if (command == 'DOOR_STILL_OPEN' && doorStillOpen != null)
              doorStillOpen();

            // --- 6. GLOBAL ---
            else if (command == 'FIX_ALL' && fixAll != null)
              fixAll();

            // --- 7. MENU BUTTONS ---
            else if (command == 'MENU_ENGINE' && menuEngine != null)
              menuEngine();
            else if (command == 'MENU_APU' && menuApu != null)
              menuApu();
            else if (command == 'MENU_BLEED' && menuBleed != null)
              menuBleed();
            else if (command == 'MENU_ELEC' && menuElec != null)
              menuElec();
            else if (command == 'MENU_FUEL' && menuFuel != null)
              menuFuel();
            else if (command == 'MENU_HYDRAULIC' && menuHydraulic != null)
              menuHydraulic();
            else if (command == 'MENU_AUTO_FLT' && menuAutoFlt != null)
              menuAutoFlt();
            else if (command == 'MENU_FLT_CTRL' && menuFltCtrl != null)
              menuFltCtrl();
            else if (command == 'MENU_LDG_GEAR' && menuLdgGear != null)
              menuLdgGear();
            else if (command == 'MENU_NAVIGATION' && menuNavigation != null)
              menuNavigation();
            else if (command == 'MENU_WORLD' && menuWorld != null) menuWorld();
          });
        } catch (e) {
          debugPrint("❌ [رادار الطيار 2]: خطأ في قراءة العطل: $e");
        }
      }
    });

    // 2. 🔥 الحل الجذري: تطبيق الصمت التام ومنع استقبال الصوت والصورة
    await pilotRoomPartTwo!.connect(
      livekitUrl,
      token,
      connectOptions: const ConnectOptions(
        autoSubscribe: false,
      ),
    );

    debugPrint(
        "✅ [رادار الطيار 2]: متصل داتا فقط ومستعد بغرفة: $cleanRoomCode");
  } catch (e) {
    debugPrint("❌ [رادار الطيار 2]: فشل الاتصال: $e");
  }
}
