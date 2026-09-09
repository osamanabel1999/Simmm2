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

import 'package:flutter/services.dart';

class SubscriptionStatusCard extends StatefulWidget {
  const SubscriptionStatusCard({
    Key? key,
    this.width,
    this.height,
    required this.status,
    required this.simulatorType,
    required this.expiryDate,
    required this.priceText,
    required this.planType,
    this.onRestorePressed,
    this.onManageAppleSubscription,
    this.onSupportPressed,
    this.onPrivacyPolicyPressed,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String status;
  final String simulatorType;
  final String expiryDate;
  final String priceText;
  final String planType;
  final Future Function()? onRestorePressed;
  final Future Function()? onManageAppleSubscription;
  final Future Function()? onSupportPressed;
  final Future Function()? onPrivacyPolicyPressed;

  @override
  _SubscriptionStatusCardState createState() => _SubscriptionStatusCardState();
}

class _SubscriptionStatusCardState extends State<SubscriptionStatusCard> {
  @override
  Widget build(BuildContext context) {
    final bool isActive =
        widget.status.toLowerCase() == 'active' || widget.status == 'نشط';

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      color: const Color(0xFF14181B),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Subscription',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0x2924D066)
                        : const Color(0x29FF5963),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF24D066)
                          : const Color(0xFFFF5963),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isActive
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: isActive
                            ? const Color(0xFF24D066)
                            : const Color(0xFFFF5963),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.status.toUpperCase(),
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFF24D066)
                              : const Color(0xFFFF5963),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Subscription Card Block
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1D2429),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF262D34),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Simulator & Plan Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.simulatorType,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Plan: ${widget.planType}',
                            style: const TextStyle(
                              color: Color(0xFF95A1AC),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.priceText,
                        style: const TextStyle(
                          color: Color(0xFF4B39EF),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    child: Divider(color: Color(0xFF262D34), height: 1),
                  ),

                  // Expiry Date Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              color: Color(0xFF95A1AC), size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Expiration Date:',
                            style: TextStyle(
                              color: Color(0xFF95A1AC),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.expiryDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons Section
            ElevatedButton.icon(
              onPressed: () async {
                if (widget.onRestorePressed != null) {
                  await widget.onRestorePressed!();
                }
              },
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Restore License'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B39EF),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () async {
                if (widget.onManageAppleSubscription != null) {
                  await widget.onManageAppleSubscription!();
                }
              },
              icon: const Icon(Icons.apple_rounded,
                  size: 20, color: Colors.white),
              label: const Text('Manage Apple Subscription'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Color(0xFF262D34), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(color: Color(0xFF262D34)),

            // Support & Policy Links
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    if (widget.onSupportPressed != null) {
                      await widget.onSupportPressed!();
                    }
                  },
                  icon: const Icon(Icons.headset_mic_rounded,
                      size: 16, color: Color(0xFF95A1AC)),
                  label: const Text(
                    'Support',
                    style: TextStyle(
                      color: Color(0xFF95A1AC),
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                    height: 14,
                    child: const VerticalDivider(color: Color(0xFF262D34))),
                TextButton.icon(
                  onPressed: () async {
                    if (widget.onPrivacyPolicyPressed != null) {
                      await widget.onPrivacyPolicyPressed!();
                    }
                  },
                  icon: const Icon(Icons.privacy_tip_rounded,
                      size: 16, color: Color(0xFF95A1AC)),
                  label: const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: Color(0xFF95A1AC),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
