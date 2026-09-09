// Automatic FlutterFlow imports
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class Bfmccheckout extends StatefulWidget {
  const Bfmccheckout({
    Key? key,
    this.width,
    this.height,
    this.monthlyPrice,
    this.yearlyPrice,
    this.lifetimePrice,
    this.onBuyMonthly,
    this.onBuyYearly,
    this.onBuyLifetime,
    this.onContactUs,
    this.onBuyBothSims,
    this.onTermsOfUse,
    this.onPrivacyPolicy,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String? monthlyPrice;
  final String? yearlyPrice;
  final String? lifetimePrice;
  final Future Function()? onBuyMonthly;
  final Future Function()? onBuyYearly;
  final Future Function()? onBuyLifetime;
  final Future Function()? onContactUs;
  final Future Function()? onBuyBothSims;
  final Future Function()? onTermsOfUse;
  final Future Function()? onPrivacyPolicy;

  @override
  _BfmccheckoutState createState() => _BfmccheckoutState();
}

class _BfmccheckoutState extends State<Bfmccheckout> {
  static const Color brandColor = Color(0xFF2081FF);
  static const Color cardBgColor = Color(0xFF161B22);
  static const Color pageBgColor = Color(0xFF0D1117);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: pageBgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Header Banner ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: brandColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: brandColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.bolt, color: brandColor, size: 18),
                  SizedBox(width: 6),
                  Text(
                    "CHOOSE YOUR ACCESS DURATION",
                    style: TextStyle(
                      color: brandColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "X-Plane Access Pass",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "All plans include full, unrestricted access to the entire application. Simply choose your preferred duration.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // --- PLAN 1: Monthly ---
            _buildPlanCard(
              title: "Monthly Pass",
              subtitle: "30 Days Access",
              price: widget.monthlyPrice ?? "\$2.99",
              period: "/ month",
              badgeText: "SHORT TERM",
              isPopular: false,
              features: [
                "100% Full App Access",
                "Valid for 30 Days",
                "Unlock All Features Instantly",
              ],
              buttonText: "Get Monthly Pass",
              onTap: widget.onBuyMonthly,
            ),

            const SizedBox(height: 20),

            // --- PLAN 2: Yearly (Featured) ---
            _buildPlanCard(
              title: "Yearly Pass",
              subtitle: "12 Months Access",
              price: widget.yearlyPrice ?? "\$12.99",
              period: "/ year",
              badgeText: "🔥 MOST POPULAR - SAVE 80%",
              isPopular: true,
              features: [
                "100% Full App Access",
                "Valid for a Full Year (365 Days)",
                "Unlock All Features Instantly",
              ],
              buttonText: "Claim Yearly Pass",
              onTap: widget.onBuyYearly,
            ),

            const SizedBox(height: 20),

            // --- PLAN 3: Lifetime ---
            _buildPlanCard(
              title: "Lifetime Pass",
              subtitle: "Permanent Access",
              price: widget.lifetimePrice ?? "\$19.99",
              period: " one-time",
              badgeText: "⚡ BEST VALUE",
              isPopular: false,
              features: [
                "100% Full App Access",
                "Unlimited Lifetime Validity",
                "Pay Once, Never Pay Again",
              ],
              buttonText: "Get Lifetime Access",
              onTap: widget.onBuyLifetime,
            ),

            const SizedBox(height: 32),

            // --- Bundle Offer (X-Plane + MSFS) ---
            InkWell(
              onTap: () async {
                if (widget.onBuyBothSims != null) {
                  await widget.onBuyBothSims!();
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      brandColor.withOpacity(0.2),
                      Colors.purpleAccent.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: brandColor.withOpacity(0.5), width: 1.5),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.flight_takeoff,
                        color: Colors.white, size: 32),
                    const SizedBox(height: 12),
                    const Text(
                      "Fly on both simulators?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Get the Ultimate Bundle (X-Plane & MSFS)\nat a massive discount! Click here for details.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- Footer (Contact & Legal Links) ---
            Divider(color: Colors.grey[800], thickness: 0.8),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                if (widget.onContactUs != null) {
                  await widget.onContactUs!();
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.headset_mic_outlined,
                        color: brandColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Need Help? Contact Support",
                      style: TextStyle(
                        color: brandColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Legal Buttons (Terms of Use & Privacy Policy) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    if (widget.onTermsOfUse != null) {
                      await widget.onTermsOfUse!();
                    }
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      "Terms of Use",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Text(
                  "•",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                InkWell(
                  onTap: () async {
                    if (widget.onPrivacyPolicy != null) {
                      await widget.onPrivacyPolicy!();
                    }
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      "Privacy Policy",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String subtitle,
    required String price,
    required String period,
    required String badgeText,
    required bool isPopular,
    required List<String> features,
    required String buttonText,
    required Future Function()? onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? brandColor : Colors.grey[800]!,
          width: isPopular ? 2.0 : 1.0,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: brandColor.withOpacity(0.25),
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subtitle.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isPopular ? brandColor : brandColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: isPopular ? Colors.white : brandColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[800], thickness: 0.8),
            const SizedBox(height: 16),
            Column(
              children: features
                  .map(
                    (feat) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: brandColor, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              feat,
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  if (onTap != null) {
                    await onTap();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPopular ? brandColor : Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: isPopular ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: brandColor,
                      width: 1.5,
                    ),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
