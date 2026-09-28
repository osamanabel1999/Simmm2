// Automatic FlutterFlow imports
import '/flutter_flow/ff_builtin_enums.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:math' as math;

import 'package:flutter_svg/flutter_svg.dart';

class PushbackControlPanel extends StatefulWidget {
  const PushbackControlPanel({
    super.key,
    this.width,
    this.height,
    this.headingText,
    this.viewAction,
    this.planAction,
    this.connectAction,
    this.reconnectAction,
    this.disconnectAction,
    this.stopAction,
  });

  final double? width;
  final double? height;

  final String? headingText;

  final Future Function()? viewAction;
  final Future Function()? planAction;
  final Future Function()? connectAction;
  final Future Function()? reconnectAction;
  final Future Function()? disconnectAction;
  final Future Function()? stopAction;

  @override
  State<PushbackControlPanel> createState() => _PushbackControlPanelState();
}

class _PushbackControlPanelState extends State<PushbackControlPanel> {
  // ============================================================
  // COLORS (الألوان بالمللي زي ما هي)
  // ============================================================
  static const Color outerBackground = Color(0xFF0E1724);
  static const Color panelBackground = Color(0xFF080B14);
  static const Color buttonBackground = Color(0xFF0A111D);
  static const Color buttonPressedBackground = Color(0xFF122235);
  static const Color panelBorder = Color(0xFF1D334E);
  static const Color buttonBorder = Color(0xFF243B57);
  static const Color blue = Color(0xFF739FD3);
  static const Color blueBright = Color(0xFF8BB8EA);
  static const Color primaryText = Color(0xFFF0F6FD);
  static const Color secondaryText = Color(0xFF8AAED8);
  static const Color mutedBlue = Color(0xFF597493);
  static const Color aircraftWhite = Color(0xFFF4FAFF);
  static const Color aircraftBlue = Color(0xFF8BBBEA);

  static const String aircraftUrl =
      'https://upload.wikimedia.org/wikipedia/commons/7/7e/Boeing_737-800_silhouette.svg';

  static const double outerMargin = 18.0;

  int? pressedButton;

  // ============================================================
  // ACTIONS
  // ============================================================
  Future<void> executeAction(int index) async {
    try {
      switch (index) {
        case 0:
          await widget.viewAction?.call();
          break;
        case 1:
          await widget.planAction?.call();
          break;
        case 2:
          await widget.connectAction?.call();
          break;
        case 3:
          await widget.reconnectAction?.call();
          break;
        case 4:
          await widget.disconnectAction?.call();
          break;
        case 5:
          await widget.stopAction?.call();
          break;
      }
    } catch (_) {}
  }

  void handlePress(int index) {
    if (!mounted) return;
    setState(() => pressedButton = index);
    executeAction(index);
    Future.delayed(const Duration(milliseconds: 165), () {
      if (!mounted) return;
      if (pressedButton == index) setState(() => pressedButton = null);
    });
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          if (!screenWidth.isFinite || screenWidth <= 0) screenWidth = 360;
          if (!screenHeight.isFinite || screenHeight <= 0) screenHeight = 640;

          final double margin = math.min(
            outerMargin,
            math.min(screenWidth * 0.035, screenHeight * 0.025),
          );

          final double panelWidth = math.max(1.0, screenWidth - (margin * 2));
          final double panelHeight = math.max(1.0, screenHeight - (margin * 2));

          return Container(
            width: screenWidth,
            height: screenHeight,
            color: outerBackground,
            padding: EdgeInsets.all(margin),
            child: Container(
              width: panelWidth,
              height: panelHeight,
              decoration: BoxDecoration(
                color: panelBackground,
                border: Border.all(color: panelBorder, width: 1.7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildResponsivePanel(panelWidth, panelHeight),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // RESPONSIVE PANEL
  // ============================================================
  Widget _buildResponsivePanel(double width, double height) {
    final double aircraftWidth = math.min(width * 0.45, 180.0);
    final double aircraftHeight = math.min(height * 0.35, 220.0);

    final double buttonHeight = math.min(height * 0.08, 48.0);
    final double mainButtonsWidth = math.min(width * 0.88, 400.0);

    final double viewWidth = math.min(width * 0.28, 110.0);
    final double viewHeight = math.min(height * 0.06, 38.0);

    // ========================================================
    // هندسة المواقع الجديدة حسب طلبك بالمللي
    // ========================================================
    final double textTopPosition = height * 0.04;

    // 1. تنزيل الطيارة مسافة بسيطة
    final double aircraftTopPosition = textTopPosition + 50.0;

    // 2. رفع الزراير لتكون تحت الطيارة مباشرة
    final double buttonsTopPosition =
        aircraftTopPosition + aircraftHeight + 25.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ====================================================
        // 1. HEADING TEXT
        // ====================================================
        Positioned(
          top: textTopPosition,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              widget.headingText ?? '000',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: math.max(18, math.min(width * 0.07, 26.0)),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.25,
                color: primaryText,
              ),
            ),
          ),
        ),

        // ====================================================
        // 2. AIRCRAFT
        // ====================================================
        Positioned(
          top: aircraftTopPosition,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: _buildAircraft(aircraftWidth, aircraftHeight),
          ),
        ),

        // ====================================================
        // 3. VIEW BUTTON
        // ====================================================
        Positioned(
          top: height * 0.03,
          right: width * 0.04,
          width: viewWidth,
          height: viewHeight,
          child: _buildButton(
            index: 0,
            label: 'VIEW',
            icon: Icons.visibility_outlined,
          ),
        ),

        // ====================================================
        // 4. MAIN BUTTONS (مترتبين تحت الطيارة مباشرة)
        // ====================================================
        Positioned(
          top: buttonsTopPosition,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: mainButtonsWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: buttonHeight,
                    width: double.infinity,
                    child: _buildButton(
                        index: 1, label: 'PLAN', icon: Icons.map_outlined),
                  ),
                  SizedBox(height: height * 0.015),
                  SizedBox(
                    height: buttonHeight,
                    width: double.infinity,
                    child: _buildButton(
                        index: 2, label: 'CONNECT', icon: Icons.link_rounded),
                  ),
                  SizedBox(height: height * 0.015),
                  SizedBox(
                    height: buttonHeight,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildButton(
                              index: 3,
                              label: 'RECONNECT',
                              icon: Icons.sync_rounded),
                        ),
                        SizedBox(width: width * 0.025),
                        Expanded(
                          child: _buildButton(
                              index: 4,
                              label: 'DISCONNECT',
                              icon: Icons.link_off_rounded),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  SizedBox(
                    height: buttonHeight,
                    width: double.infinity,
                    child: _buildButton(
                        index: 5, label: 'STOP', icon: Icons.stop_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AIRCRAFT
  // ============================================================
  Widget _buildAircraft(double width, double height) {
    return Center(
      child: Transform.rotate(
        angle: math.pi,
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                aircraftWhite,
                aircraftWhite,
                aircraftBlue,
                aircraftWhite
              ],
              stops: [0.0, 0.30, 0.70, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: SvgPicture.network(
            aircraftUrl,
            width: width,
            height: height,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            placeholderBuilder: (context) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUTTON (تم بناء نظام التوسيط والأيقونة بالظبط زي ما طلبت)
  // ============================================================
  Widget _buildButton({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final bool isPressed = pressedButton == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => handlePress(index),
      child: AnimatedScale(
        scale: isPressed ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 95),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 145),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isPressed ? buttonPressedBackground : buttonBackground,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: buttonBorder, width: 1.25),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 120),
                    opacity: isPressed ? 1.0 : 0.0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.0,
                          colors: [
                            blueBright.withOpacity(0.22),
                            blue.withOpacity(0.10),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.48, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(isPressed ? 0.035 : 0.012),
                            Colors.transparent,
                            Colors.black.withOpacity(0.025),
                          ],
                          stops: const [0.0, 0.48, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // ====================================================
                // نظام الـ Stack عشان يسنتر الكلام مع الأيقونة في النص بالمللي
                // ====================================================
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Stack(
                      alignment: Alignment
                          .center, // بيخلي الجروب ده في نص الزرار أفقياً وعمودياً
                      children: [
                        // 1. الجروب (الأيقونة + مسافة صغيرة + النص)
                        Row(
                          mainAxisSize: MainAxisSize
                              .min, // بياخد مساحته بس عشان يفضل متسنتر
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              icon,
                              size: 20.0,
                              color: isPressed ? primaryText : secondaryText,
                            ),
                            const SizedBox(
                                width:
                                    8.0), // المسافة الصغيرة بين الأيقونة والنص
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize:
                                        15.0, // حجم مناسب وموحد لكل الزراير
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.25,
                                    color:
                                        isPressed ? primaryText : secondaryText,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // 2. السهم اليمين (Chevron) مفصول على الطرف لوحده (تم إخفاؤه من الأزرار الخمسة)
                        if (index == 0)
                          Positioned(
                            right: 0,
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: 20.0,
                              color: isPressed ? blueBright : mutedBlue,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
