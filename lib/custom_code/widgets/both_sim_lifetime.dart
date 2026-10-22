// Automatic FlutterFlow imports
import '/flutter_flow/ff_builtin_enums.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:ui';

class BothSimLifetime extends StatefulWidget {
  const BothSimLifetime({
    Key? key,
    this.width,
    this.height,
    this.lifetimePrice,
    this.onBuyLifetime,
    this.onContactUs,
    this.onTermsOfUse,
    this.onPrivacyPolicy,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String? lifetimePrice;
  final Future Function()? onBuyLifetime;
  final Future Function()? onContactUs;
  final Future Function()? onTermsOfUse;
  final Future Function()? onPrivacyPolicy;

  @override
  _BothSimLifetimeState createState() => _BothSimLifetimeState();
}

class _BothSimLifetimeState extends State<BothSimLifetime> {
  // Your Exact Design System Colors applied to the Premium Layout
  static const Color _bg = Color(0xFF0B111A);
  static const Color _card = Color(0xFF101923);
  static const Color _fieldBg = Color(0xFF0B1521);
  static const Color _border = Color(0xFF26364D);
  static const Color _accent = Color(0xFF639DF0);
  static const Color _buttonDark = Color(0xFF15335E);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _muted = Color(0xFF8B949E);
  static const Color _heading = Color(0xFF9BB8E1);
  static const Color _good = Color(0xFF69F0AE);

  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    // 3 Days rolling cycle for Urgency
    const int cycleMs = 3 * 24 * 60 * 60 * 1000;
    int nowMs = DateTime.now().millisecondsSinceEpoch;
    int remainingMs = cycleMs - (nowMs % cycleMs);

    _endDate = DateTime.now().add(Duration(milliseconds: remainingMs));
    _timeLeft = Duration(milliseconds: remainingMs);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft.inSeconds > 0) {
            _timeLeft = _timeLeft - const Duration(seconds: 1);
          } else {
            _timeLeft = const Duration(days: 3);
            _endDate = DateTime.now().add(const Duration(days: 3));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Regex to extract price and add exactly 25% to original price!
  Map<String, String> _parsePriceInfo(String fullText) {
    String prefix = "\$";
    String numberStr = "39.99";
    String suffix = "";
    String originalPriceStr = "\$53.32";

    try {
      final regex = RegExp(r'^([^\d]*)(\d+(?:\.\d+)?)\s*(.*)$');
      final match = regex.firstMatch(fullText);

      if (match != null) {
        prefix = match.group(1)?.trim() ?? "";
        numberStr = match.group(2) ?? "39.99";
        suffix = match.group(3)?.trim() ?? "";

        double currentPriceNum = double.parse(numberStr);
        // Calculate original price (25% off means current / 0.75)
        double originalPriceNum = currentPriceNum / 0.75;

        String symbol = prefix.isNotEmpty ? prefix : "\$";
        originalPriceStr = '$symbol${originalPriceNum.toStringAsFixed(2)}';
      }
    } catch (e) {
      // Fallback
    }

    return {
      'mainPrice': '$prefix$numberStr',
      'suffix': suffix,
      'originalPrice': originalPriceStr
    };
  }

  @override
  Widget build(BuildContext context) {
    final String currentPriceRaw = widget.lifetimePrice ?? "\$39.99 one-time";

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: _bg, // Using your exact main background
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Premium Header Text ---
            const Text(
              "Ultimate 2-in-1\nSimulator Pass",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Take absolute control over both MSFS and X-Plane. Secure your lifetime access today with a massive 25% flash discount!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // --- Elegant Countdown Timer ---
            _buildTimerWidget(),

            const SizedBox(height: 32),

            // --- Premium Lifetime Card (25% OFF) ---
            _buildPremiumLifetimeCard(currentPriceRaw),

            const SizedBox(height: 48),

            // --- Footer ---
            const Divider(color: _border, thickness: 1),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                if (widget.onContactUs != null) {
                  await widget.onContactUs!();
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.support_agent_rounded, color: _muted, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Need Help? Contact Support",
                      style: TextStyle(
                        color: _muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Legal Links ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    if (widget.onTermsOfUse != null)
                      await widget.onTermsOfUse!();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      "Terms of Use",
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const Text("•", style: TextStyle(color: _border, fontSize: 12)),
                InkWell(
                  onTap: () async {
                    if (widget.onPrivacyPolicy != null)
                      await widget.onPrivacyPolicy!();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      "Privacy Policy",
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerWidget() {
    String days = _timeLeft.inDays.toString().padLeft(2, '0');
    String hours = (_timeLeft.inHours % 24).toString().padLeft(2, '0');
    String minutes = (_timeLeft.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (_timeLeft.inSeconds % 60).toString().padLeft(2, '0');

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    String endDateStr = "${months[_endDate.month - 1]} ${_endDate.day}";

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: _fieldBg, // Using your field background for the timer
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border), // Your exact border color
            boxShadow: const [
              BoxShadow(
                color: Color(0x16000000), // Subtle shadow
                blurRadius: 15,
                offset: Offset(0, 5),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _timeBox(days, "DAYS"),
              _timeColon(),
              _timeBox(hours, "HRS"),
              _timeColon(),
              _timeBox(minutes, "MINS"),
              _timeColon(),
              _timeBox(seconds, "SECS"),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Flash Sale Ends $endDateStr",
          style: const TextStyle(
            color: _muted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _timeBox(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: _white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: _heading,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _timeColon() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: EdgeInsets.only(bottom: 14),
        child: Text(
          ":",
          style: TextStyle(
            color: _border,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumLifetimeCard(String rawPriceString) {
    final priceData = _parsePriceInfo(rawPriceString);
    final String mainPrice = priceData['mainPrice']!;
    final String suffixText = priceData['suffix']!;
    final String originalPrice = priceData['originalPrice']!;

    // --- High Conversion Marketing Copy (Tattbeel) ---
    List<String> hypedFeatures = [
      "Full Access to MSFS 2020, 2024 & X-Plane 11/12",
      "Unrestricted Lifetime App Access",
      "Free Updates Forever (Never pay again)",
      "Instant Unlock to All Premium Tools",
      "Connect to unlimited devices seamlessly",
      "Priority VIP Customer Support",
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _card, // Your specific card background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 15,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Elegant Discount Badge using your _good color (25% OFF)
          Positioned(
            top: -14,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _good,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _good.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Text(
                "SAVE 25% TODAY",
                style: TextStyle(
                  color: Color(0xFF0B111A), // Dark text on light green
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ULTIMATE 2-IN-1 PASS",
                  style: TextStyle(
                    color: _accent, // Using your blue accent
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // --- Smart Pricing Area ---
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      mainPrice,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    if (suffixText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 2),
                        child: Text(
                          suffixText,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, left: 8),
                      child: Text(
                        originalPrice,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: _muted,
                          decorationThickness: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Text(
                  "One payment. Endless flights.",
                  style: TextStyle(
                    color: _muted,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 32),

                // Features List
                Column(
                  children: hypedFeatures
                      .map((feat) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: _accent, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feat,
                                    style: const TextStyle(
                                      color: _white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),

                const SizedBox(height: 32),

                // CTA Button (Using your active button style)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (widget.onBuyLifetime != null) {
                        await widget.onBuyLifetime!();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonDark,
                      foregroundColor: _white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: _accent, width: 1.5),
                      ),
                      shadowColor: _accent.withOpacity(0.5),
                    ).copyWith(
                      elevation:
                          MaterialStateProperty.all(8), // subtle glow effect
                    ),
                    child: const Text(
                      "CLAIM 25% OFF NOW",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
