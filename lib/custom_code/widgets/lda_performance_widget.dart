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
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

class LdaPerformanceWidget extends StatefulWidget {
  const LdaPerformanceWidget({
    Key? key,
    this.width,
    this.height,
    required this.pilotId, // تم إضافة الـ ID عشان زرار جلب الداتا يشتغل
    this.onCalculatePressed,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String pilotId; // لاستخدامه في جلب SimBrief

  // الأكشن الأصلي بدون أي تغيير في الـ Arguments نهائياً!
  final Future Function(
    String acType,
    double gw,
    double aptElev,
    String config,
    String aice,
    String revInop,
    double rwyLen,
    double rwyHdg,
    double slope,
    String rwyCond,
    String autobrake,
    double qnh,
    double temp,
    double windDir,
    double windSpd,
  )? onCalculatePressed;

  @override
  State<LdaPerformanceWidget> createState() => _LdaPerformanceWidgetState();
}

class _LdaPerformanceWidgetState extends State<LdaPerformanceWidget> {
  // ============================================================
  // COLORS (نفس الألوان الأصلية وتطابق الصورة الاحترافية)
  // ============================================================
  static const Color outerBackground = Color(0xFF0E1724);
  static const Color panelBackground = Color(0xFF080B14);
  static const Color inputBackground = Color(0xFF0A111D);
  static const Color panelBorder = Color(0xFF1D334E);
  static const Color inputBorder = Color(0xFF243B57);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueBright = Color(0xFF8BB8EA);
  static const Color primaryText = Color(0xFFF0F6FD);
  static const Color secondaryText = Color(0xFF8AAED8);
  static const Color errorBorder = Colors.redAccent;

  // ألوان إضافية تم تعريفها
  static const Color cDanger = Color(0xFFFF5252);
  static const Color cSafe = Color(0xFF69F0AE);
  static const Color efbWhite = Color(0xFFFFFFFF);

  // ============================================================
  // CONTROLLERS & STATE VARIABLES
  // ============================================================
  String _acType = 'A320';

  // Segmented Control States (القيم الافتراضية)
  String _config = 'FULL';
  String _antiIce = 'OFF';
  String _revInopDisplay = 'NONE'; // زراير العرض: NONE, ONE, BOTH
  String _rwyCond = 'DRY';
  String _autobrake = 'LOW';

  final TextEditingController _gwCtrl =
      TextEditingController(text: "51.7"); // القيمة الافتراضية الثابتة
  final TextEditingController _aptElevCtrl = TextEditingController();
  final TextEditingController _rwyLenCtrl = TextEditingController();
  final TextEditingController _rwyHdgCtrl = TextEditingController();
  final TextEditingController _slopeCtrl = TextEditingController();
  final TextEditingController _qnhCtrl = TextEditingController();
  final TextEditingController _tempCtrl = TextEditingController();
  final TextEditingController _windDirCtrl = TextEditingController();
  final TextEditingController _windSpdCtrl = TextEditingController();

  bool _hasAttemptedSubmit = false;
  bool _isFetchingData = false;

  @override
  void dispose() {
    _gwCtrl.dispose();
    _aptElevCtrl.dispose();
    _rwyLenCtrl.dispose();
    _rwyHdgCtrl.dispose();
    _slopeCtrl.dispose();
    _qnhCtrl.dispose();
    _tempCtrl.dispose();
    _windDirCtrl.dispose();
    _windSpdCtrl.dispose();
    super.dispose();
  }

  // ============================================================
  // FETCH LIVE DATA (SimBrief + AviationWeather API)
  // ============================================================
  Future<void> _fetchLiveData() async {
    String cleanId = widget.pilotId.trim();

    if (cleanId.isEmpty) {
      _showErrorSnackBar("No Pilot ID provided! Please set your ID first.");
      return;
    }

    setState(() {
      _isFetchingData = true;
    });

    try {
      // 1. Fetch from SimBrief
      bool isNumeric = RegExp(r'^[0-9]+$').hasMatch(cleanId);
      String queryParam = isNumeric ? "userid" : "username";
      final sbUrl = Uri.parse(
          "https://www.simbrief.com/api/xml.fetcher.php?$queryParam=${Uri.encodeComponent(cleanId)}&json=1");

      final sbResponse =
          await http.get(sbUrl).timeout(const Duration(seconds: 10));

      if (sbResponse.statusCode != 200) {
        _showErrorSnackBar("SimBrief Error: Unable to fetch flight plan.");
        setState(() => _isFetchingData = false);
        return;
      }

      final sbData = json.decode(sbResponse.body);

      if (sbData['general'] == null || sbData['destination'] == null) {
        _showErrorSnackBar("No active flight plan found on SimBrief.");
        setState(() => _isFetchingData = false);
        return;
      }

      // Extract Destination Data
      final dest = sbData['destination'];
      String destIcao = dest['icao_code']?.toString() ?? "";
      String rwyStr = dest['plan_rwy']?.toString() ?? "";
      double rwyElev =
          double.tryParse(dest['elevation']?.toString() ?? "0") ?? 0.0;

      // Extract Runway Data from TLR if available
      double rwyLen = 0.0;
      final tlr = sbData['tlr'];
      if (tlr != null &&
          tlr['landing'] != null &&
          tlr['landing']['runway'] != null &&
          (tlr['landing']['runway'] as List).isNotEmpty) {
        var rwyData = tlr['landing']['runway'][0];
        // Convert feet to meters
        rwyLen =
            (double.tryParse(rwyData['length_lda']?.toString() ?? "0") ?? 0) *
                0.3048;
      }

      // Format Runway Heading (e.g. 09L -> 090)
      String cleanRwy = rwyStr.replaceAll(RegExp(r'[A-Za-z]'), '');
      int hdgInt = int.tryParse(cleanRwy) ?? 0;
      double rwyHdg = hdgInt > 0 ? (hdgInt * 10).toDouble() : 0.0;

      // Update UI with SimBrief Data
      _aptElevCtrl.text = rwyElev.round().toString();
      if (rwyLen > 0) _rwyLenCtrl.text = rwyLen.round().toString();
      _rwyHdgCtrl.text = rwyHdg.round().toString().padLeft(3, '0');
      _slopeCtrl.text =
          "0.0"; // Defaulting to 0 unless exact slope is available

      // 2. Fetch Live METAR from AviationWeather
      if (destIcao.isNotEmpty) {
        final metarUrl = Uri.parse(
            "https://aviationweather.gov/api/data/metar?ids=$destIcao&format=json");
        final metarResponse =
            await http.get(metarUrl).timeout(const Duration(seconds: 5));

        if (metarResponse.statusCode == 200) {
          List<dynamic> metarList = json.decode(metarResponse.body);
          if (metarList.isNotEmpty) {
            var metarData = metarList[0];

            double temp =
                double.tryParse(metarData['temp']?.toString() ?? "15") ?? 15.0;
            double qnh =
                double.tryParse(metarData['altim']?.toString() ?? "1013") ??
                    1013.0;
            double wSpd =
                double.tryParse(metarData['wspd']?.toString() ?? "0") ?? 0.0;
            double wDir =
                double.tryParse(metarData['wdir']?.toString() ?? "0") ?? 0.0;

            if (wDir == 0 && wSpd > 0)
              wDir = 360.0; // Variable/North adjustment

            _tempCtrl.text = temp.round().toString();
            _qnhCtrl.text = qnh.round().toString();
            _windSpdCtrl.text = wSpd.round().toString();
            _windDirCtrl.text = wDir.round().toString().padLeft(3, '0');

            _showSuccessSnackBar(
                "Live data fetched for $destIcao successfully!");
          } else {
            _showErrorSnackBar("No METAR data found for $destIcao.");
          }
        }
      }
    } catch (e) {
      _showErrorSnackBar("Network timeout or fetch error.");
    }

    setState(() {
      _isFetchingData = false;
    });
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: cDanger),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: cSafe,
          duration: const Duration(seconds: 2)),
    );
  }

  // ============================================================
  // VALIDATION LOGIC
  // ============================================================
  bool _validateForm() {
    setState(() {
      _hasAttemptedSubmit = true;
    });

    if (_gwCtrl.text.trim().isEmpty) return false;
    if (_aptElevCtrl.text.trim().isEmpty) return false;
    if (_rwyLenCtrl.text.trim().isEmpty) return false;
    if (_rwyHdgCtrl.text.trim().isEmpty) return false;
    if (_slopeCtrl.text.trim().isEmpty) return false;
    if (_qnhCtrl.text.trim().isEmpty) return false;
    if (_tempCtrl.text.trim().isEmpty) return false;
    if (_windDirCtrl.text.trim().isEmpty) return false;
    if (_windSpdCtrl.text.trim().isEmpty) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: outerBackground,
      child: SafeArea(
        // تم تغليف المحتوى داخل Stack لعمل الشريط العائم
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 600;
                // استخدام ScrollView كلي للشاشة كلها لتجنب أي قطع في الشاشات الصغيرة
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Header ---
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0, left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Landing Performance Data Entry',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: primaryText)),
                            SizedBox(height: 4),
                            Text(
                                'Enter the parameters below or fetch live data to calculate landing performance.',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: secondaryText)),
                          ],
                        ),
                      ),

                      // --- Top Fetch Button (مكان شيك ومناسب جداً فوق) ---
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isFetchingData ? null : _fetchLiveData,
                          icon: _isFetchingData
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      color: efbWhite, strokeWidth: 2))
                              : const Icon(Icons.cloud_sync, color: efbWhite),
                          label: const Text(
                              'FETCH LIVE DATA FROM SIMBRIEF & METAR',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: efbWhite,
                                  letterSpacing: 1.0)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: panelBorder,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Layout ---
                      if (isMobile) ...[
                        // ترتيب الموبايل: الكروت تحت بعض
                        _buildAircraftPanel(),
                        const SizedBox(height: 16),
                        _buildRunwayPanel(),
                        const SizedBox(height: 24),
                        _buildCalculateButton(),
                      ] else ...[
                        // ترتيب الأيباد: عمودين جنب بعض
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildAircraftPanel()),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildRunwayPanel(),
                                  const SizedBox(height: 24),
                                  _buildCalculateButton(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(
                          height:
                              40), // مساحة إضافية في الأسفل لعدم تداخل المحتوى مع الشريط
                    ],
                  ),
                );
              },
            ),

            // إضافة الشريط العائم في الأسفل تماماً
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildHomeIndicator(
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PANEL BUILDERS
  // ============================================================

  Widget _buildAircraftPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: panelBackground,
        border: Border.all(color: panelBorder, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelHeader(Icons.flight, 'Aircraft & Weather'),
          const SizedBox(height: 24),

          _buildAircaftTypeDropdown(),
          const SizedBox(height: 16),

          _buildTextFieldRow('Gross Weight', _gwCtrl,
              isDecimal: true,
              isError: _hasAttemptedSubmit && _gwCtrl.text.isEmpty,
              suffixLabel: '(Tons)'),
          const SizedBox(height: 20),

          _buildSegmentedRow('Configuration', ['FULL', 'CONF 3'], _config,
              (val) => setState(() => _config = val)),
          const SizedBox(height: 20),

          _buildSegmentedRow('A/ICE', ['OFF', 'Engine', 'Total'], _antiIce,
              (val) => setState(() => _antiIce = val)),
          const SizedBox(height: 20),

          // Reversers Mapping to Action Arguments: (NONE -> NO, ONE/BOTH -> INOP for legacy logic)
          _buildSegmentedRow('Reversers', ['NONE', 'ONE', 'BOTH'],
              _revInopDisplay, (val) => setState(() => _revInopDisplay = val)),

          const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(color: panelBorder, thickness: 1)),

          _buildTextFieldRow('QNH (hPa)', _qnhCtrl,
              isError: _hasAttemptedSubmit && _qnhCtrl.text.isEmpty),
          const SizedBox(height: 16),
          _buildTextFieldRow('Temperature (°C)', _tempCtrl,
              isDecimal: true,
              allowNegative: true,
              isError: _hasAttemptedSubmit && _tempCtrl.text.isEmpty),
          const SizedBox(height: 16),
          _buildDoubleTextFieldRow(
              'Wind', _windDirCtrl, _windSpdCtrl, 'Dir (Deg)', 'Spd (Kt)'),
        ],
      ),
    );
  }

  Widget _buildRunwayPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: panelBackground,
        border: Border.all(color: panelBorder, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelHeader(Icons.add_road, 'Runway & Braking'),
          const SizedBox(height: 24),

          _buildTextFieldRow('Airport Elev (ft)', _aptElevCtrl,
              isError: _hasAttemptedSubmit && _aptElevCtrl.text.isEmpty),
          const SizedBox(height: 16),
          _buildTextFieldRow('Runway Length (m)', _rwyLenCtrl,
              isError: _hasAttemptedSubmit && _rwyLenCtrl.text.isEmpty),
          const SizedBox(height: 16),
          _buildTextFieldRow('Runway Heading', _rwyHdgCtrl,
              isError: _hasAttemptedSubmit && _rwyHdgCtrl.text.isEmpty),
          const SizedBox(height: 16),
          _buildTextFieldRow('Slope (%)', _slopeCtrl,
              isDecimal: true,
              allowNegative: true,
              isError: _hasAttemptedSubmit && _slopeCtrl.text.isEmpty),

          const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(color: panelBorder, thickness: 1)),

          // تم استخدام القيم الأساسية القديمة عشان الأكشن يشتغل صح
          _buildSegmentedRow('Runway Condition', ['DRY', 'WET', 'ICE', 'SLUSH'],
              _rwyCond, (val) => setState(() => _rwyCond = val)),
          const SizedBox(height: 20),
          _buildSegmentedRow('Autobrake', ['LOW', 'MED', 'MAX'], _autobrake,
              (val) => setState(() => _autobrake = val)),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_validateForm() && widget.onCalculatePressed != null) {
            double parsedGw = double.tryParse(_gwCtrl.text.trim()) ?? 0.0;
            double parsedAptElev =
                double.tryParse(_aptElevCtrl.text.trim()) ?? 0.0;
            double parsedRwyLen =
                double.tryParse(_rwyLenCtrl.text.trim()) ?? 0.0;
            double parsedRwyHdg =
                double.tryParse(_rwyHdgCtrl.text.trim()) ?? 0.0;
            double parsedSlope = double.tryParse(_slopeCtrl.text.trim()) ?? 0.0;
            double parsedQnh = double.tryParse(_qnhCtrl.text.trim()) ?? 0.0;
            double parsedTemp = double.tryParse(_tempCtrl.text.trim()) ?? 0.0;
            double parsedWindDir =
                double.tryParse(_windDirCtrl.text.trim()) ?? 0.0;
            double parsedWindSpd =
                double.tryParse(_windSpdCtrl.text.trim()) ?? 0.0;

            // تحويل الزرار بتاع الشاشة (NONE, ONE, BOTH) للقيمة القديمة (NO, INOP) اللي الأكشن منتظرها
            String actionRevValue = _revInopDisplay == 'NONE' ? 'NO' : 'INOP';

            // تمرير نفس الـ Arguments اللي الأكشن مستنيها بدون أي تغيير!
            await widget.onCalculatePressed!(
              _acType,
              parsedGw,
              parsedAptElev,
              _config,
              _antiIce,
              actionRevValue,
              parsedRwyLen,
              parsedRwyHdg,
              parsedSlope,
              _rwyCond,
              _autobrake,
              parsedQnh,
              parsedTemp,
              parsedWindDir,
              parsedWindSpd,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text('CALCULATE',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryText,
                letterSpacing: 1.2)),
      ),
    );
  }

  // ============================================================
  // COMPONENT BUILDERS (Segmented Buttons & Fields)
  // ============================================================

  Widget _buildHomeIndicator({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
        alignment: Alignment.center,
        child: Container(
          width: 130,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: blueBright, size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryText)),
      ],
    );
  }

  Widget _buildAircaftTypeDropdown() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
            flex: 2,
            child: Text('A/C Type',
                style: TextStyle(
                    color: secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500))),
        Expanded(
          flex: 3,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: inputBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: inputBorder)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _acType,
                dropdownColor: panelBackground,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: secondaryText),
                style: const TextStyle(
                    color: primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
                items: ['A320']
                    .map((String value) => DropdownMenuItem<String>(
                        value: value, child: Text(value)))
                    .toList(),
                onChanged: (val) => setState(() => _acType = val!),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldRow(String label, TextEditingController controller,
      {bool isError = false,
      bool isDecimal = false,
      bool allowNegative = false,
      String suffixLabel = ""}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(label,
                    style: TextStyle(
                        color: isError ? errorBorder : secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                if (suffixLabel.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(suffixLabel,
                      style: TextStyle(
                          color: isError
                              ? errorBorder
                              : secondaryText.withOpacity(0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.w400)),
                ]
              ],
            )),
        Expanded(
          flex: 3,
          child: _buildBaseTextField(controller,
              isError: isError,
              isDecimal: isDecimal,
              allowNegative: allowNegative),
        ),
      ],
    );
  }

  Widget _buildDoubleTextFieldRow(String label, TextEditingController ctrl1,
      TextEditingController ctrl2, String hint1, String hint2) {
    bool isErr1 = _hasAttemptedSubmit && ctrl1.text.isEmpty;
    bool isErr2 = _hasAttemptedSubmit && ctrl2.text.isEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(
                    color: secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500))),
        Expanded(
            flex: 1,
            child: _buildBaseTextField(ctrl1, isError: isErr1, hint: hint1)),
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child:
                Text("/", style: TextStyle(color: inputBorder, fontSize: 18))),
        Expanded(
            flex: 1,
            child: _buildBaseTextField(ctrl2, isError: isErr2, hint: hint2)),
      ],
    );
  }

  Widget _buildSegmentedRow(String label, List<String> options,
      String currentValue, Function(String) onSelected) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(
                    color: secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500))),
        Expanded(
          flex: 3,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
                color: inputBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: inputBorder)),
            child: Row(
              children: options.map((opt) {
                bool isSelected = opt == currentValue;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onSelected(opt),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        opt,
                        style: TextStyle(
                          color: isSelected ? Colors.white : secondaryText,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBaseTextField(TextEditingController controller,
      {bool isError = false,
      bool isDecimal = false,
      bool allowNegative = false,
      String? hint}) {
    String regexPattern;
    if (isDecimal && allowNegative)
      regexPattern = r'^-?\d*\.?\d*';
    else if (isDecimal)
      regexPattern = r'^\d*\.?\d*';
    else if (allowNegative)
      regexPattern = r'^-?\d*';
    else
      regexPattern = r'^\d*';

    return SizedBox(
      height: 40,
      child: TextFormField(
        controller: controller,
        style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryText),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.numberWithOptions(
            decimal: isDecimal, signed: allowNegative),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(regexPattern))
        ],
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: inputBorder, fontSize: 12),
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: inputBackground,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: isError ? errorBorder : inputBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: isError ? errorBorder : blue, width: 1.5)),
        ),
        onChanged: (val) {
          if (_hasAttemptedSubmit) setState(() {});
        },
      ),
    );
  }
}
