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

class TopBannerWidget extends StatefulWidget {
  const TopBannerWidget({
    Key? key,
    this.width,
    this.height,
    // ==========================================
    // 7 Parameters (متغيرات الـ API)
    // ==========================================
    this.latValue,
    this.lonValue,
    this.iasValue,
    this.altValue,
    this.hdgValue,
    this.simSpeedValue,
    this.connectionStatus,
    this.connectionColor, // المتغير الخاص بلون حالة الاتصال
  }) : super(key: key);

  final double? width;
  final double? height;

  // المتغيرات
  final String? latValue;
  final String? lonValue;
  final String? iasValue;
  final String? altValue;
  final String? hdgValue;
  final String? simSpeedValue;
  final String? connectionStatus;
  final Color? connectionColor;

  @override
  State<TopBannerWidget> createState() => _TopBannerWidgetState();
}

class _TopBannerWidgetState extends State<TopBannerWidget> {
  // الألوان مطابقة للصورة تماماً
  final Color bgColor = const Color(0xFF0F1115);
  final Color cardColor = const Color(0xFF15191E);
  final Color borderColor = const Color(0xFF2A2E35);
  final Color labelColor = const Color(0xFF8B949E);
  final Color valueColor = const Color(0xFF3B82F6);
  final Color dangerColor = const Color(0xFFE53935);

  // تصميم صف الداتا الصغير (مثلاً LAT و 0.0)
  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 28, // عرض ثابت للكلمة
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: 'Monospace',
          ),
        ),
      ],
    );
  }

  // تصميم عمود الداتا الفردي (مثلاً HDG أو SIM SPEED)
  Widget _buildDataColumn(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: 'Monospace',
          ),
        ),
      ],
    );
  }

  // الفاصل الرأسي
  Widget _buildVerticalDivider(bool isMobile) {
    return Container(
      width: 1,
      height: 24,
      color: borderColor,
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 6.0 : 12.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    // استخدام LayoutBuilder لمعرفة حجم الشاشة وعمل الـ Responsive
    return LayoutBuilder(
      builder: (context, constraints) {
        // إذا كان العرض أقل من 600 بيكسل، نعتبره موبايل
        final bool isMobile = constraints.maxWidth < 600;

        return Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? 65.0, // ارتفاع متناسب لحل الـ Overflow
          color: bgColor,
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // الكروت تاخد الارتفاع بالكامل
            children: [
              // ==========================================
              // الكارت الأول: الإحداثيات (Globe)
              // ==========================================
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 16.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.language,
                        color: valueColor, size: isMobile ? 18 : 22),
                    SizedBox(width: isMobile ? 6 : 12),
                    FittedBox(
                      // لحماية النصوص من الـ Overflow الرأسي
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDataRow("LAT", widget.latValue ?? "0.0"),
                          const SizedBox(height: 2),
                          _buildDataRow("LON", widget.lonValue ?? "0.0"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // ==========================================
              // الكارت الثاني: بيانات الطيران (Airplane)
              // ==========================================
              // تم وضع الكارت في Expanded لكي يملأ عرض الشاشة (للآيباد والموبايل)
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: isMobile ? 6.0 : 16.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceEvenly, // توزيع المسافات بشكل ذكي
                    children: [
                      // الأيقونة والسرعة/الارتفاع
                      Flexible(
                        flex: 3,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            children: [
                              Icon(Icons.flight,
                                  color: valueColor, size: isMobile ? 18 : 22),
                              SizedBox(width: isMobile ? 6 : 12),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDataRow("IAS", widget.iasValue ?? "0"),
                                  const SizedBox(height: 2),
                                  _buildDataRow("ALT", widget.altValue ?? "0"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      _buildVerticalDivider(isMobile),

                      // الاتجاه (HDG)
                      Flexible(
                        flex: 2,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _buildDataColumn(
                              "HDG", widget.hdgValue ?? "000°"),
                        ),
                      ),

                      _buildVerticalDivider(isMobile),

                      // سرعة المحاكي (SIM SPEED)
                      Flexible(
                        flex: 2,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _buildDataColumn(
                              "SIM SPEED", widget.simSpeedValue ?? "1"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // ==========================================
              // الكارت الثالث: حالة الاتصال (Responsive)
              // ==========================================
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: isMobile ? 12.0 : 16.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // الدايرة دي هتفضل موجودة دايماً (بتنور باللون المطلوب)
                    Icon(
                      Icons.radio_button_checked,
                      color: widget.connectionColor ?? dangerColor,
                      size: isMobile ? 22 : 16,
                    ),

                    // لو الشاشة مش موبايل (يعني آيباد) نعرض الكلمة والأيقونة التانية
                    if (!isMobile) ...[
                      const SizedBox(width: 10),
                      Text(
                        widget.connectionStatus ?? "Disconnected",
                        style: TextStyle(
                          color: widget.connectionColor ?? dangerColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.adjust,
                        color: widget.connectionColor ?? dangerColor,
                        size: 16,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
