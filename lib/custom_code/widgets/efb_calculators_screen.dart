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

import 'dart:ui';
import 'dart:math' as math;

class EfbCalculatorsScreen extends StatefulWidget {
  const EfbCalculatorsScreen({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  _EfbCalculatorsScreenState createState() => _EfbCalculatorsScreenState();
}

class _EfbCalculatorsScreenState extends State<EfbCalculatorsScreen> {
  // 0 = TOD Calc, 1 = Converter
  int _selectedTab = 0;

  // التحكم في ظهور الكيبورد
  bool _isKeyboardVisible = false;
  String _activeField = '';

  // ==========================================
  // TOD Variables
  // ==========================================
  String tod_current = '';
  String tod_target = '';
  String tod_gs = '';
  String tod_fpa = '3.0';

  String tod_dist = '-';
  String tod_time = '-';
  String tod_vs = '-';

  // ==========================================
  // Converter Variables
  // ==========================================
  String conv_inhg = '';
  String conv_hpa = '';

  String conv_kg = '';
  String conv_lbs = '';

  String conv_c = '';
  String conv_f = '';

  String conv_ft = '';
  String conv_m = '';

  String conv_fuel_l = '';
  String conv_fuel_sg = '0.803'; // Standard Jet-A1 SG
  String conv_fuel_kg = '';

  // ==========================================
  // Logic Engine & Precision Formatting
  // ==========================================

  // دالة مسؤولة عن إظهار الأرقام بدقة متناهية مع إزالة الأصفار غير الضرورية
  String _formatExact(double value) {
    String s = value.toStringAsFixed(4);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0*$'), ''); // إزالة الأصفار من اليمين
      if (s.endsWith('.')) {
        s = s.substring(0, s.length - 1); // إزالة العلامة العشرية لوحدها
      }
    }
    return s;
  }

  void _onNumpadTap(String value) {
    setState(() {
      String currentValue = _getFieldValue(_activeField);

      if (value == '.' && currentValue.contains('.')) return;

      if (currentValue == '0' && value != '.') {
        _setFieldValue(_activeField, value);
      } else {
        _setFieldValue(_activeField, currentValue + value);
      }

      _calculateAll();
    });
  }

  void _onNumpadDel() {
    setState(() {
      String currentValue = _getFieldValue(_activeField);
      if (currentValue.isNotEmpty) {
        _setFieldValue(
            _activeField, currentValue.substring(0, currentValue.length - 1));
        _calculateAll();
      }
    });
  }

  void _onNumpadClear() {
    setState(() {
      _setFieldValue(_activeField, '');
      _calculateAll();
    });
  }

  void _onNumpadToggleSign() {
    setState(() {
      String currentValue = _getFieldValue(_activeField);
      if (currentValue.isEmpty) return;
      if (currentValue.startsWith('-')) {
        _setFieldValue(_activeField, currentValue.substring(1));
      } else {
        _setFieldValue(_activeField, '-' + currentValue);
      }
      _calculateAll();
    });
  }

  String _getFieldValue(String id) {
    switch (id) {
      case 'tod_current':
        return tod_current;
      case 'tod_target':
        return tod_target;
      case 'tod_gs':
        return tod_gs;
      case 'tod_fpa':
        return tod_fpa;
      case 'conv_inhg':
        return conv_inhg;
      case 'conv_hpa':
        return conv_hpa;
      case 'conv_kg':
        return conv_kg;
      case 'conv_lbs':
        return conv_lbs;
      case 'conv_c':
        return conv_c;
      case 'conv_f':
        return conv_f;
      case 'conv_ft':
        return conv_ft;
      case 'conv_m':
        return conv_m;
      case 'conv_fuel_l':
        return conv_fuel_l;
      case 'conv_fuel_sg':
        return conv_fuel_sg;
      default:
        return '';
    }
  }

  void _setFieldValue(String id, String value) {
    switch (id) {
      case 'tod_current':
        tod_current = value;
        break;
      case 'tod_target':
        tod_target = value;
        break;
      case 'tod_gs':
        tod_gs = value;
        break;
      case 'tod_fpa':
        tod_fpa = value;
        break;
      case 'conv_inhg':
        conv_inhg = value;
        break;
      case 'conv_hpa':
        conv_hpa = value;
        break;
      case 'conv_kg':
        conv_kg = value;
        break;
      case 'conv_lbs':
        conv_lbs = value;
        break;
      case 'conv_c':
        conv_c = value;
        break;
      case 'conv_f':
        conv_f = value;
        break;
      case 'conv_ft':
        conv_ft = value;
        break;
      case 'conv_m':
        conv_m = value;
        break;
      case 'conv_fuel_l':
        conv_fuel_l = value;
        break;
      case 'conv_fuel_sg':
        conv_fuel_sg = value;
        break;
    }
  }

  void _calculateAll() {
    // 1. حساب الـ TOD
    double altC = double.tryParse(tod_current) ?? 0;
    double altT = double.tryParse(tod_target) ?? 0;
    double gs = double.tryParse(tod_gs) ?? 0;
    double fpa = double.tryParse(tod_fpa) ?? 0;

    if (altC > altT && gs > 0 && fpa > 0) {
      double delta = altC - altT;
      double dist = delta / (math.tan(fpa * math.pi / 180) * 6076.115);
      tod_dist = _formatExact(dist);

      double vs = gs * 101.268 * math.tan(fpa * math.pi / 180);
      tod_vs = "-${vs.toStringAsFixed(0)}";

      double time = (dist / gs) * 60;
      tod_time = _formatExact(time);
    } else {
      tod_dist = '-';
      tod_vs = '-';
      tod_time = '-';
    }

    // 2. التحويلات بدقة متناهية
    if (_activeField == 'conv_inhg') {
      double v = double.tryParse(conv_inhg) ?? 0;
      conv_hpa = v == 0 ? '' : _formatExact(v * 33.86389);
    } else if (_activeField == 'conv_hpa') {
      double v = double.tryParse(conv_hpa) ?? 0;
      conv_inhg = v == 0 ? '' : _formatExact(v / 33.86389);
    }

    if (_activeField == 'conv_kg') {
      double v = double.tryParse(conv_kg) ?? 0;
      conv_lbs = v == 0 ? '' : _formatExact(v * 2.2046226218);
    } else if (_activeField == 'conv_lbs') {
      double v = double.tryParse(conv_lbs) ?? 0;
      conv_kg = v == 0 ? '' : _formatExact(v / 2.2046226218);
    }

    if (_activeField == 'conv_c') {
      double v = double.tryParse(conv_c) ?? 0;
      if (conv_c.isNotEmpty && conv_c != '-')
        conv_f = _formatExact((v * 9 / 5) + 32);
    } else if (_activeField == 'conv_f') {
      double v = double.tryParse(conv_f) ?? 0;
      if (conv_f.isNotEmpty && conv_f != '-')
        conv_c = _formatExact((v - 32) * 5 / 9);
    }

    if (_activeField == 'conv_ft') {
      double v = double.tryParse(conv_ft) ?? 0;
      conv_m = v == 0 ? '' : _formatExact(v * 0.3048);
    } else if (_activeField == 'conv_m') {
      double v = double.tryParse(conv_m) ?? 0;
      conv_ft = v == 0 ? '' : _formatExact(v / 0.3048);
    }

    if (_activeField == 'conv_fuel_l' || _activeField == 'conv_fuel_sg') {
      double l = double.tryParse(conv_fuel_l) ?? 0;
      double sg = double.tryParse(conv_fuel_sg) ?? 0;
      if (l > 0 && sg > 0) {
        conv_fuel_kg = _formatExact(l * sg);
      } else {
        conv_fuel_kg = '';
      }
    }
  }

  // ==========================================
  // UI Builder
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: const Color(0xFF101923),
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              _isKeyboardVisible = false;
              _activeField = '';
            });
          },
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeaderTabs(),
                  Container(height: 1.5, color: const Color(0xFF26364D)),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 20,
                          bottom: _isKeyboardVisible ? 320 : 20),
                      child: _selectedTab == 0
                          ? _buildTodCalculator()
                          : _buildConverters(),
                    ),
                  ),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                bottom: _isKeyboardVisible ? 0 : -350,
                left: 0,
                right: 0,
                child: _buildHiddenNumpad(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==== [ تصميم التابات العلوية ] ====
  Widget _buildHeaderTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildTabButton("TOD CALC", 0),
          const SizedBox(width: 12),
          _buildTabButton("CONVERTERS", 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isActive = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
            _isKeyboardVisible = false;
            _activeField = '';
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF639DF0).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isActive ? const Color(0xFF639DF0) : const Color(0xFF26364D),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF639DF0)
                    : const Color(0xFF8B949E),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==== [ صفحة حاسبة الـ TOD ] ====
  Widget _buildTodCalculator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("DESCENT PARAMETERS",
            style: TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 13,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildContainerBlock(
          child: Column(
            children: [
              _buildMockField(
                  'tod_current', 'Current Altitude', 'FT', tod_current),
              _buildMockField(
                  'tod_target', 'Target Altitude', 'FT', tod_target),
              _buildMockField('tod_gs', 'Ground Speed', 'KT', tod_gs),
              _buildMockField('tod_fpa', 'Descent Angle (FPA)', 'DEG', tod_fpa,
                  isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text("CALCULATION RESULTS",
            style: TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 13,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildResultCard(),
      ],
    );
  }

  Widget _buildResultCard() {
    return _buildContainerBlock(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildResultItem("DISTANCE", tod_dist, "NM"),
            _buildResultItem("TIME", tod_time, "MIN"),
            _buildResultItem("V/S REQ", tod_vs, "FPM"),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String title, String value, String unit) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value,
                style: const TextStyle(
                    color: Color(0xFF639DF0),
                    fontSize: 22,
                    fontWeight: FontWeight.w900)),
            const SizedBox(width: 4),
            Text(unit,
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  // ==== [ صفحة المحولات ] ====
  Widget _buildConverters() {
    return Column(
      children: [
        _buildConverterBlock("ALTITUDE & DISTANCE (HIGH PRECISION)", [
          _buildMockField('conv_ft', 'Feet', 'FT', conv_ft),
          _buildMockField('conv_m', 'Meters', 'M', conv_m, isLast: true),
        ]),
        _buildConverterBlock("MASS & WEIGHT", [
          _buildMockField('conv_kg', 'Kilograms', 'KG', conv_kg),
          _buildMockField('conv_lbs', 'Pounds', 'LBS', conv_lbs, isLast: true),
        ]),
        _buildConverterBlock("ALTIMETRY (PRESSURE)", [
          _buildMockField('conv_inhg', 'Inches of Mercury', 'inHg', conv_inhg),
          _buildMockField('conv_hpa', 'Hectopascals', 'hPa', conv_hpa,
              isLast: true),
        ]),
        _buildConverterBlock("FUEL DENSITY CALCULATOR", [
          _buildMockField(
              'conv_fuel_l', 'Uplift Volume', 'LITERS', conv_fuel_l),
          _buildMockField(
              'conv_fuel_sg', 'Specific Gravity', 'SG', conv_fuel_sg),
          _buildMockField(
              'conv_fuel_kg', 'Total Weight (Auto)', 'KG', conv_fuel_kg,
              isLast: true, isReadOnlyDisplay: true),
        ]),
        _buildConverterBlock("TEMPERATURE", [
          _buildMockField('conv_c', 'Celsius', '°C', conv_c),
          _buildMockField('conv_f', 'Fahrenheit', '°F', conv_f, isLast: true),
        ]),
      ],
    );
  }

  Widget _buildConverterBlock(String title, List<Widget> fields) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildContainerBlock(
            child: Column(children: fields),
          ),
        ],
      ),
    );
  }

  // ==== [ تصميم الخانات المخصصة ] ====
  Widget _buildMockField(String id, String label, String unit, String value,
      {bool isLast = false, bool isReadOnlyDisplay = false}) {
    bool isActive = _activeField == id && !isReadOnlyDisplay;
    return GestureDetector(
      onTap: isReadOnlyDisplay
          ? null
          : () {
              setState(() {
                _activeField = id;
                _isKeyboardVisible = true;
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF639DF0).withOpacity(0.08)
              : Colors.transparent,
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : const BorderSide(color: Color(0xFF26364D), width: 1),
            left: isActive
                ? const BorderSide(color: Color(0xFF639DF0), width: 4)
                : const BorderSide(color: Colors.transparent, width: 4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            Row(
              children: [
                Text(
                  value.isEmpty ? (isActive ? '_' : '0') : value,
                  style: TextStyle(
                    color: isReadOnlyDisplay
                        ? const Color(0xFF8B949E)
                        : (isActive ? const Color(0xFF639DF0) : Colors.white),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Text(unit,
                    style: const TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildContainerBlock({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101923),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF26364D), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: child,
      ),
    );
  }

  // ==== [ تصميم الكيبورد المدمج (المخفي) بتأثير الضغط ] ====
  Widget _buildHiddenNumpad() {
    return Container(
      height: 320,
      decoration: const BoxDecoration(
        color: Color(0xFF0D141C),
        border: Border(top: BorderSide(color: Color(0xFF26364D), width: 1.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black54, blurRadius: 20, offset: Offset(0, -5))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // شريط إغلاق الكيبورد
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Color(0xFF26364D), width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("KEYPAD INPUT",
                      style: TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isKeyboardVisible = false;
                        _activeField = '';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF639DF0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text("Done",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),

            // أزرار الكيبورد مع تأثير الـ Ripple
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                        child: Row(children: [
                      _buildNumBtn('7'),
                      _buildNumBtn('8'),
                      _buildNumBtn('9')
                    ])),
                    Expanded(
                        child: Row(children: [
                      _buildNumBtn('4'),
                      _buildNumBtn('5'),
                      _buildNumBtn('6')
                    ])),
                    Expanded(
                        child: Row(children: [
                      _buildNumBtn('1'),
                      _buildNumBtn('2'),
                      _buildNumBtn('3')
                    ])),
                    Expanded(
                        child: Row(children: [
                      _buildNumBtn('.'),
                      _buildNumBtn('0'),
                      _buildActionBtn(Icons.backspace_rounded, _onNumpadDel)
                    ])),
                    Expanded(
                        child: Row(
                      children: [
                        _buildTextActionBtn('CLEAR', _onNumpadClear,
                            color: const Color(0xFFEF4444)),
                        _buildTextActionBtn('+ / -', _onNumpadToggleSign,
                            color: const Color(0xFF8B949E)),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==== [ تعديل الأزرار لإظهار تأثير الضغط بوضوح ] ====
  Widget _buildNumBtn(String digit) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFF26364D).withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF26364D)),
            ),
            child: InkWell(
              onTap: () => _onNumpadTap(digit),
              borderRadius: BorderRadius.circular(10),
              splashColor: const Color(0xFF639DF0).withOpacity(0.4),
              highlightColor: const Color(0xFF639DF0).withOpacity(0.2),
              child: Center(
                child: Text(digit,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFF26364D).withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF26364D)),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              splashColor: const Color(0xFF639DF0).withOpacity(0.4),
              highlightColor: const Color(0xFF639DF0).withOpacity(0.2),
              child: Center(
                child: Icon(icon, color: Colors.white70, size: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextActionBtn(String title, VoidCallback onTap,
      {required Color color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              splashColor: color.withOpacity(0.4),
              highlightColor: color.withOpacity(0.2),
              child: Center(
                child: Text(title,
                    style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
