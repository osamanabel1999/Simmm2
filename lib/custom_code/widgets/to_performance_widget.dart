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

import 'package:flutter/services.dart'; // ضروري عشان الـ InputFormatters

import 'dart:math' as math;

class ToPerformanceWidget extends StatefulWidget {
  const ToPerformanceWidget({
    Key? key,
    this.width,
    this.height,
    // الأكشن الوحيد اللي هيبعتلك الـ 15 قيمة مرة واحدة
    this.onCalculatePressed,
  }) : super(key: key);

  final double? width;
  final double? height;

  // تعريف الأكشن بالـ 15 متغير بالـ Types الجديدة
  final Future Function(
    String acType,
    double gw,
    double cg,
    String config,
    String aice,
    String aircond,
    double rwyLen,
    double rwyHdg,
    double slope,
    String rwyCond,
    double aptElev,
    double qnh,
    double temp,
    double windDir,
    double windSpd,
  )? onCalculatePressed;

  @override
  State<ToPerformanceWidget> createState() => _ToPerformanceWidgetState();
}

class _ToPerformanceWidgetState extends State<ToPerformanceWidget> {
  // ============================================================
  // COLORS
  // ============================================================
  static const Color outerBackground = Color(0xFF0E1724);
  static const Color panelBackground = Color(0xFF080B14);
  static const Color inputBackground = Color(0xFF0A111D);
  static const Color panelBorder = Color(0xFF1D334E);
  static const Color inputBorder = Color(0xFF243B57);
  static const Color blue = Color(0xFF739FD3);
  static const Color blueBright = Color(0xFF8BB8EA);
  static const Color primaryText = Color(0xFFF0F6FD);
  static const Color secondaryText = Color(0xFF8AAED8);
  static const Color errorBorder = Colors.redAccent; // لون الـ Error

  static const double outerMargin = 18.0;

  // ============================================================
  // CONTROLLERS & STATE VARIABLES
  // ============================================================

  // Dropdown Variables
  String? _acType;
  String? _config;
  String? _antiIce;
  String? _airCond;
  String? _rwyCond;

  // Text Controllers
  final TextEditingController _gwCtrl = TextEditingController();
  final TextEditingController _cgCtrl = TextEditingController();
  final TextEditingController _rwyLenCtrl = TextEditingController();
  final TextEditingController _rwyHdgCtrl = TextEditingController();
  final TextEditingController _slopeCtrl = TextEditingController();
  final TextEditingController _aptElevCtrl = TextEditingController();
  final TextEditingController _qnhCtrl = TextEditingController();
  final TextEditingController _tempCtrl = TextEditingController();
  final TextEditingController _windDirCtrl = TextEditingController();
  final TextEditingController _windSpdCtrl = TextEditingController();

  // تتبع الأخطاء (لو الـ Key بـ true معناه الخانة فيها خطأ)
  bool _hasAttemptedSubmit = false;

  @override
  void dispose() {
    _gwCtrl.dispose();
    _cgCtrl.dispose();
    _rwyLenCtrl.dispose();
    _rwyHdgCtrl.dispose();
    _slopeCtrl.dispose();
    _aptElevCtrl.dispose();
    _qnhCtrl.dispose();
    _tempCtrl.dispose();
    _windDirCtrl.dispose();
    _windSpdCtrl.dispose();
    super.dispose();
  }

  // ============================================================
  // VALIDATION LOGIC
  // ============================================================
  bool _validateForm() {
    setState(() {
      _hasAttemptedSubmit = true;
    });

    if (_acType == null || _acType!.isEmpty) return false;
    if (_gwCtrl.text.trim().isEmpty) return false;
    if (_cgCtrl.text.trim().isEmpty) return false;
    if (_config == null || _config!.isEmpty) return false;
    if (_antiIce == null || _antiIce!.isEmpty) return false;
    if (_airCond == null || _airCond!.isEmpty) return false;
    if (_rwyLenCtrl.text.trim().isEmpty) return false;
    if (_rwyHdgCtrl.text.trim().isEmpty) return false;
    if (_slopeCtrl.text.trim().isEmpty) return false;
    if (_rwyCond == null || _rwyCond!.isEmpty) return false;
    if (_aptElevCtrl.text.trim().isEmpty) return false;
    if (_qnhCtrl.text.trim().isEmpty) return false;
    if (_tempCtrl.text.trim().isEmpty) return false;
    if (_windDirCtrl.text.trim().isEmpty) return false;
    if (_windSpdCtrl.text.trim().isEmpty) return false;

    return true; // كله تمام
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: panelBackground,
                border: Border.all(color: panelBorder, width: 2.0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // =======================================
                  // HEADING
                  // =======================================
                  const Center(
                    child: Text(
                      'T/O Performance Calculation',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: blueBright,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // =======================================
                  // FORM FIELDS
                  // =======================================

                  Expanded(
                    child: _buildDropdownRow(
                      'A/C Type:',
                      ['A320'],
                      _acType,
                      (val) => _acType = val,
                      isError: _hasAttemptedSubmit &&
                          (_acType == null || _acType!.isEmpty),
                    ),
                  ),
                  Expanded(
                    child: _buildTextFieldRow(
                      'Gross Weight: (kg)', _gwCtrl,
                      isDecimal: true, // يقبل فواصل
                      isError:
                          _hasAttemptedSubmit && _gwCtrl.text.trim().isEmpty,
                    ),
                  ),
                  Expanded(
                    child: _buildTextFieldRow(
                      'CG:', _cgCtrl,
                      isDecimal: true, // يقبل فواصل
                      isError:
                          _hasAttemptedSubmit && _cgCtrl.text.trim().isEmpty,
                    ),
                  ),

                  Expanded(
                    child: _buildDropdownRow(
                      'Configuration:',
                      ['CONF 1+F', 'CONF 2', 'CONF 3'],
                      _config,
                      (val) => _config = val,
                      isError: _hasAttemptedSubmit &&
                          (_config == null || _config!.isEmpty),
                    ),
                  ),
                  Expanded(
                    child: _buildDropdownRow(
                      'A/ICE:',
                      ['OFF', 'Engine', 'Total'],
                      _antiIce,
                      (val) => _antiIce = val,
                      isError: _hasAttemptedSubmit &&
                          (_antiIce == null || _antiIce!.isEmpty),
                    ),
                  ),
                  Expanded(
                    child: _buildDropdownRow(
                      'Air Conditioning:',
                      ['ON', 'OFF'],
                      _airCond,
                      (val) => _airCond = val,
                      isError: _hasAttemptedSubmit &&
                          (_airCond == null || _airCond!.isEmpty),
                    ),
                  ),

                  Expanded(
                    child: _buildTextFieldRow(
                      'Runway Length: (m)', _rwyLenCtrl,
                      isDecimal: false, // أرقام صحيحة فقط
                      isError: _hasAttemptedSubmit &&
                          _rwyLenCtrl.text.trim().isEmpty,
                    ),
                  ),
                  Expanded(
                    child: _buildTextFieldRow(
                      'Runway Heading:',
                      _rwyHdgCtrl,
                      isDecimal: false,
                      isError: _hasAttemptedSubmit &&
                          _rwyHdgCtrl.text.trim().isEmpty,
                    ),
                  ),
                  Expanded(
                    child: _buildTextFieldRow(
                      'Slope:', _slopeCtrl,
                      isDecimal: true, // يقبل فواصل
                      isError:
                          _hasAttemptedSubmit && _slopeCtrl.text.trim().isEmpty,
                    ),
                  ),

                  Expanded(
                    child: _buildDropdownRow(
                      'Runway Condition:',
                      ['DRY', 'WET'],
                      _rwyCond,
                      (val) => _rwyCond = val,
                      isError: _hasAttemptedSubmit &&
                          (_rwyCond == null || _rwyCond!.isEmpty),
                    ),
                  ),
                  Expanded(
                    child: _buildTextFieldRow(
                      'Airport Elevation: (ft)',
                      _aptElevCtrl,
                      isDecimal: false,
                      isError: _hasAttemptedSubmit &&
                          _aptElevCtrl.text.trim().isEmpty,
                    ),
                  ),

                  // =======================================
                  // DOUBLE FIELDS
                  // =======================================
                  Expanded(
                    child: _buildDoubleRow(
                      'QNH: (hpa)',
                      _qnhCtrl,
                      'Temperature: (°C)',
                      _tempCtrl,
                      isError1:
                          _hasAttemptedSubmit && _qnhCtrl.text.trim().isEmpty,
                      isError2:
                          _hasAttemptedSubmit && _tempCtrl.text.trim().isEmpty,
                      isDecimal1: false,
                      isDecimal2: false,
                    ),
                  ),
                  Expanded(
                    child: _buildDoubleRow(
                      'Wind: (Deg)',
                      _windDirCtrl,
                      'speed: (kt)',
                      _windSpdCtrl,
                      isError1: _hasAttemptedSubmit &&
                          _windDirCtrl.text.trim().isEmpty,
                      isError2: _hasAttemptedSubmit &&
                          _windSpdCtrl.text.trim().isEmpty,
                      isDecimal1: false,
                      isDecimal2: false,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // =======================================
                  // CALCULATE BUTTON
                  // =======================================
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // تنفيذ الفاليديشن
                        if (_validateForm()) {
                          if (widget.onCalculatePressed != null) {
                            // تحويل القيم إلى double قبل الإرسال
                            double parsedGw =
                                double.tryParse(_gwCtrl.text.trim()) ?? 0.0;
                            double parsedCg =
                                double.tryParse(_cgCtrl.text.trim()) ?? 0.0;
                            double parsedRwyLen =
                                double.tryParse(_rwyLenCtrl.text.trim()) ?? 0.0;
                            double parsedRwyHdg =
                                double.tryParse(_rwyHdgCtrl.text.trim()) ?? 0.0;
                            double parsedSlope =
                                double.tryParse(_slopeCtrl.text.trim()) ?? 0.0;
                            double parsedAptElev =
                                double.tryParse(_aptElevCtrl.text.trim()) ??
                                    0.0;
                            double parsedQnh =
                                double.tryParse(_qnhCtrl.text.trim()) ?? 0.0;
                            double parsedTemp =
                                double.tryParse(_tempCtrl.text.trim()) ?? 0.0;
                            double parsedWindDir =
                                double.tryParse(_windDirCtrl.text.trim()) ??
                                    0.0;
                            double parsedWindSpd =
                                double.tryParse(_windSpdCtrl.text.trim()) ??
                                    0.0;

                            await widget.onCalculatePressed!(
                              _acType!,
                              parsedGw,
                              parsedCg,
                              _config!,
                              _antiIce!,
                              _airCond!,
                              parsedRwyLen,
                              parsedRwyHdg,
                              parsedSlope,
                              _rwyCond!,
                              parsedAptElev,
                              parsedQnh,
                              parsedTemp,
                              parsedWindDir,
                              parsedWindSpd,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Calculate',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primaryText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // WIDGET BUILDERS
  // ============================================================

  Widget _buildTextFieldRow(String label, TextEditingController controller,
      {bool isError = false, bool isDecimal = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: _labelStyle(isError: isError),
          ),
        ),
        Expanded(
          flex: 3,
          child: _buildBaseTextField(controller,
              isError: isError, isDecimal: isDecimal),
        ),
      ],
    );
  }

  Widget _buildDropdownRow(String label, List<String> items,
      String? currentValue, Function(String?) onChanged,
      {bool isError = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: _labelStyle(isError: isError),
          ),
        ),
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<String>(
            value: currentValue,
            dropdownColor: panelBackground,
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: isError ? errorBorder : secondaryText),
            decoration: _inputDecoration(isError: isError),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
            hint: Text(
              'Select...',
              style: TextStyle(
                  color: isError ? errorBorder.withOpacity(0.7) : secondaryText,
                  fontSize: 13),
            ),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                onChanged(val);
                // بنعمل إعادة تقييم للـ Error State عشان الأحمر يختفي بمجرد الاختيار
                if (_hasAttemptedSubmit) _validateForm();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDoubleRow(String label1, TextEditingController ctrl1,
      String label2, TextEditingController ctrl2,
      {bool isError1 = false,
      bool isError2 = false,
      bool isDecimal1 = false,
      bool isDecimal2 = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(label1, style: _labelStyle(isError: isError1)),
        ),
        Expanded(
          flex: 2,
          child: _buildBaseTextField(ctrl1,
              isError: isError1, isDecimal: isDecimal1),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(label2, style: _labelStyle(isError: isError2)),
        ),
        Expanded(
          flex: 2,
          child: _buildBaseTextField(ctrl2,
              isError: isError2, isDecimal: isDecimal2),
        ),
      ],
    );
  }

  Widget _buildBaseTextField(TextEditingController controller,
      {bool isError = false, bool isDecimal = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      textAlign: TextAlign.center,
      decoration: _inputDecoration(isError: isError),

      // هنا تحديد نوع الكيبورد
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),

      // هنا الفلترة عشان نمنع أي حروف تتكتب نهائياً
      inputFormatters: [
        isDecimal
            ? FilteringTextInputFormatter.allow(
                RegExp(r'^\d+\.?\d{0,}')) // يسمح بأرقام ونقطة واحدة للكسور
            : FilteringTextInputFormatter.digitsOnly, // يسمح بأرقام فقط
      ],
      onChanged: (val) {
        if (_hasAttemptedSubmit) {
          setState(() {}); // إعادة البناء لإخفاء الأحمر فوراً عند الكتابة
        }
      },
    );
  }

  TextStyle _labelStyle({bool isError = false}) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: isError ? errorBorder : primaryText,
    );
  }

  InputDecoration _inputDecoration({bool isError = false}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      filled: true,
      fillColor: inputBackground,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color: isError ? errorBorder : inputBorder,
            width: isError ? 1.5 : 1.25),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isError ? errorBorder : blue, width: 2.0),
      ),
    );
  }
}
