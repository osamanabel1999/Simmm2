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
import 'package:purchases_flutter/purchases_flutter.dart';

class SmartSubscriptionWidget extends StatefulWidget {
  const SmartSubscriptionWidget({
    Key? key,
    this.width,
    this.height,
    this.onManageAppleSubscription,
    this.onSupportPressed,
    this.onPrivacyPolicyPressed,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Future Function()? onManageAppleSubscription;
  final Future Function()? onSupportPressed;
  final Future Function()? onPrivacyPolicyPressed;

  @override
  _SmartSubscriptionWidgetState createState() =>
      _SmartSubscriptionWidgetState();
}

class _SmartSubscriptionWidgetState extends State<SmartSubscriptionWidget> {
  bool _isLoading = true;
  List<Map<String, String>> _activeSubscriptions = [];

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionData();
  }

  Future<void> _fetchSubscriptionData() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      Offerings offerings = await Purchases.getOfferings();
      List<Map<String, String>> subs = [];

      // 1. فحص الباقة الشاملة (MSFS & X-Plane)
      EntitlementInfo? comboEntitlement =
          customerInfo.entitlements.all['simulator_station_msfs_xplane'];

      if (comboEntitlement != null && comboEntitlement.isActive) {
        // لو عنده الباقة الشاملة، نعرض كارت واحد فقط
        subs.add(await _buildSubDetails(
            comboEntitlement, 'MSFS & X-PLANE', offerings));
      } else {
        // 2. لو مفيش باقة شاملة، نفحص الباقات الفردية
        EntitlementInfo? msfsEntitlement =
            customerInfo.entitlements.all['simulator_station_pro'];
        EntitlementInfo? xplaneEntitlement =
            customerInfo.entitlements.all['simulator_station_xplane'];

        // لو شاري MSFS لوحدها
        if (msfsEntitlement != null && msfsEntitlement.isActive) {
          subs.add(await _buildSubDetails(
              msfsEntitlement, 'MSFS 2020/2024', offerings));
        }

        // لو شاري X-Plane لوحدها
        if (xplaneEntitlement != null && xplaneEntitlement.isActive) {
          subs.add(
              await _buildSubDetails(xplaneEntitlement, 'X-PLANE', offerings));
        }
      }

      if (mounted) {
        setState(() {
          _activeSubscriptions = subs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching subscription data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, String>> _buildSubDetails(
      EntitlementInfo entitlement, String title, Offerings offerings) async {
    String planType = 'Monthly Pass';
    String formattedDate = 'Lifetime';
    String priceText = '\$0.00';

    String productId = entitlement.productIdentifier.toLowerCase();

    // استنتاج نوع الخطة بذكاء
    if (productId.contains('lifetime') || entitlement.expirationDate == null) {
      planType = 'Lifetime Pass';
      formattedDate = 'Lifetime';
    } else if (productId.contains('yearly') ||
        productId.contains('annual') ||
        productId.contains('1y')) {
      planType = 'Yearly Pass';
    } else {
      planType = 'Monthly Pass';
    }

    // معالجة تاريخ الانتهاء بأمان تام لمنع الكراش
    if (planType != 'Lifetime Pass' && entitlement.expirationDate != null) {
      try {
        dynamic expDate = entitlement.expirationDate;
        DateTime? parsedDate;
        if (expDate is DateTime) {
          parsedDate = expDate;
        } else if (expDate is String && expDate.toString().isNotEmpty) {
          parsedDate = DateTime.tryParse(expDate.toString());
        }

        if (parsedDate != null) {
          DateTime localDate = parsedDate.toLocal();
          formattedDate =
              "${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}";
        }
      } catch (e) {
        debugPrint('Error parsing date: $e');
      }
    }

    // جلب السعر الحي من متجر أبل لعدم رفض التطبيق
    try {
      bool priceFound = false;
      if (offerings.current != null) {
        for (var package in offerings.current!.availablePackages) {
          if (package.storeProduct.identifier.toLowerCase() == productId) {
            priceText = package.storeProduct.priceString;
            priceFound = true;
            break;
          }
        }
      }

      // لو السعر مجاش من الباقات الحالية، بنجيبه مباشرة من الـ Products
      if (!priceFound) {
        List<StoreProduct> products =
            await Purchases.getProducts([entitlement.productIdentifier]);
        if (products.isNotEmpty) {
          priceText = products.first.priceString;
        }
      }
    } catch (e) {
      debugPrint('Error fetching price: $e');
    }

    return {
      'simulatorType': title,
      'planType': planType,
      'expiryDate': formattedDate,
      'priceText': priceText,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = _activeSubscriptions.isNotEmpty;
    final String statusText = isActive ? 'ACTIVE' : 'INACTIVE';

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      color: const Color(0xFF14181B),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4B39EF)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // رأس الشاشة: حالة الاشتراك
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
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
                              statusText,
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

                  // نظام التوليد التلقائي للكروت (كارت واحد شامل أو كروت فردية)
                  if (isActive)
                    ..._activeSubscriptions.map((sub) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildSubscriptionCard(
                          simulatorType: sub['simulatorType']!,
                          planType: sub['planType']!,
                          priceText: sub['priceText']!,
                          expiryDate: sub['expiryDate']!,
                        ),
                      );
                    }).toList()
                  else
                    _buildSubscriptionCard(
                      simulatorType: 'NO SIMULATOR',
                      planType: 'No Active Plan',
                      priceText: '\$0.00',
                      expiryDate: 'Not Active',
                    ),

                  const SizedBox(height: 8),

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
                      side: const BorderSide(
                          color: Color(0xFF262D34), width: 1.5),
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

                  // الدعم وسياسة الخصوصية
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
                          child:
                              const VerticalDivider(color: Color(0xFF262D34))),
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

  // دالة بناء كارت الاشتراك الواحد
  Widget _buildSubscriptionCard({
    required String simulatorType,
    required String planType,
    required String priceText,
    required String expiryDate,
  }) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    simulatorType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Plan: $planType',
                    style: const TextStyle(
                      color: Color(0xFF95A1AC),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                priceText,
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
                expiryDate,
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
    );
  }
}
