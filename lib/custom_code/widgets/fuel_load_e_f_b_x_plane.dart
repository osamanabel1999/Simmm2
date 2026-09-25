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

// تم إيقاف استدعاءات الباك إند التي تسببت في الخطأ
// import '/backend/backend.dart';
// import '/backend/schema/structs/index.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FuelLoadEFBXPlane extends StatefulWidget {
  const FuelLoadEFBXPlane({
    Key? key,
    this.width,
    this.height,
    this.updateTotalFuel,
    this.updateCenterFuel,
    this.updateLInnerFuel,
    this.updateRInnerFuel,
    this.updateLOuterFuel,
    this.updateROuterFuel,
  }) : super(key: key);

  final double? width;
  final double? height;

  // تم إرجاع الكول باك بالاسم الموحد (fuelValue) كما طلبت لتعمل في الواجهة بدون Unknown
  final Future Function(double fuelValue)? updateTotalFuel;
  final Future Function(double fuelValue)? updateCenterFuel;
  final Future Function(double fuelValue)? updateLInnerFuel;
  final Future Function(double fuelValue)? updateRInnerFuel;
  final Future Function(double fuelValue)? updateLOuterFuel;
  final Future Function(double fuelValue)? updateROuterFuel;

  @override
  _FuelLoadEFBXPlaneState createState() => _FuelLoadEFBXPlaneState();
}

class _FuelLoadEFBXPlaneState extends State<FuelLoadEFBXPlane> {
  bool _isLoading = true;

  List<Map<String, dynamic>> _profiles = [];
  Map<String, dynamic> _currentProfile = {};

  // Fuel Values
  double _totalFuel = 0;
  double _centerFuel = 0;
  double _lInnerFuel = 0;
  double _rInnerFuel = 0;
  double _lOuterFuel = 0;
  double _rOuterFuel = 0;

  final Map<String, dynamic> _defaultA320 = {
    'name': 'A320 (Default)',
    'totalMax': 18676.0,
    'centerMax': 6479.0,
    'lInnerMax': 5430.0,
    'rInnerMax': 5430.0,
    'lOuterMax': 692.0,
    'rOuterMax': 692.0,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getStringList('aircraft_profiles');
    final lastSelected = prefs.getString('last_selected_aircraft');

    _profiles = [_defaultA320];

    if (profilesJson != null) {
      for (var jsonStr in profilesJson) {
        try {
          final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
          // Ensuring correct types
          decoded['totalMax'] = (decoded['totalMax'] as num).toDouble();
          decoded['centerMax'] = (decoded['centerMax'] as num).toDouble();
          decoded['lInnerMax'] = (decoded['lInnerMax'] as num).toDouble();
          decoded['rInnerMax'] = (decoded['rInnerMax'] as num).toDouble();
          decoded['lOuterMax'] = (decoded['lOuterMax'] as num).toDouble();
          decoded['rOuterMax'] = (decoded['rOuterMax'] as num).toDouble();
          _profiles.add(decoded);
        } catch (e) {
          debugPrint("Error loading profile: $e");
        }
      }
    }

    _currentProfile = _profiles.firstWhere(
      (p) => p['name'] == lastSelected,
      orElse: () => _defaultA320,
    );

    _setInitialValues(_currentProfile);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final customProfiles =
        _profiles.where((p) => p['name'] != 'A320 (Default)').toList();
    final profilesJson = customProfiles.map((p) => jsonEncode(p)).toList();

    await prefs.setStringList('aircraft_profiles', profilesJson);
    await prefs.setString('last_selected_aircraft', _currentProfile['name']);
  }

  void _setInitialValues(Map<String, dynamic> profile) {
    if (profile['name'] == 'A320 (Default)') {
      _centerFuel = 3200;
      _lInnerFuel = 2500;
      _rInnerFuel = 2500;
      _lOuterFuel = 300;
      _rOuterFuel = 300;
    } else {
      _centerFuel = profile['centerMax'] / 2;
      _lInnerFuel = profile['lInnerMax'] / 2;
      _rInnerFuel = profile['rInnerMax'] / 2;
      _lOuterFuel = profile['lOuterMax'] / 2;
      _rOuterFuel = profile['rOuterMax'] / 2;
    }
    // تحديث التوتال بناءً على مجموع التنكات
    _totalFuel =
        _centerFuel + _lInnerFuel + _rInnerFuel + _lOuterFuel + _rOuterFuel;
  }

  void _switchProfile(Map<String, dynamic> profile) {
    setState(() {
      _currentProfile = profile;
      _setInitialValues(profile);
    });
    _saveData();
  }

  void _onTotalFuelChanged(double newTotal) {
    setState(() {
      _totalFuel = newTotal;
      double sumMax = _currentProfile['centerMax'] +
          _currentProfile['lInnerMax'] +
          _currentProfile['rInnerMax'] +
          _currentProfile['lOuterMax'] +
          _currentProfile['rOuterMax'];

      if (sumMax > 0) {
        // حساب نسبة التوتال الجديد بالنسبة للسعة القصوى وتطبيقها على جميع التنكات
        double ratio = newTotal / sumMax;
        _centerFuel = _currentProfile['centerMax'] * ratio;
        _lInnerFuel = _currentProfile['lInnerMax'] * ratio;
        _rInnerFuel = _currentProfile['rInnerMax'] * ratio;
        _lOuterFuel = _currentProfile['lOuterMax'] * ratio;
        _rOuterFuel = _currentProfile['rOuterMax'] * ratio;
      }
    });

    // إرسال القيم للمحاكي
    widget.updateTotalFuel?.call(_totalFuel);
    widget.updateCenterFuel?.call(_centerFuel);
    widget.updateLInnerFuel?.call(_lInnerFuel);
    widget.updateRInnerFuel?.call(_rInnerFuel);
    widget.updateLOuterFuel?.call(_lOuterFuel);
    widget.updateROuterFuel?.call(_rOuterFuel);
  }

  void _onIndividualTankChanged(String tankType, double newVal) {
    setState(() {
      if (tankType == 'center') _centerFuel = newVal;
      if (tankType == 'lInner') _lInnerFuel = newVal;
      if (tankType == 'rInner') _rInnerFuel = newVal;
      if (tankType == 'lOuter') _lOuterFuel = newVal;
      if (tankType == 'rOuter') _rOuterFuel = newVal;

      // تجميع القيم الجديدة وتحديث التوتال
      _totalFuel =
          _centerFuel + _lInnerFuel + _rInnerFuel + _lOuterFuel + _rOuterFuel;
    });

    // إرسال أمر التانك المعدل بالإضافة لتحديث التوتال للمحاكي
    if (tankType == 'center') widget.updateCenterFuel?.call(_centerFuel);
    if (tankType == 'lInner') widget.updateLInnerFuel?.call(_lInnerFuel);
    if (tankType == 'rInner') widget.updateRInnerFuel?.call(_rInnerFuel);
    if (tankType == 'lOuter') widget.updateLOuterFuel?.call(_lOuterFuel);
    if (tankType == 'rOuter') widget.updateROuterFuel?.call(_rOuterFuel);

    widget.updateTotalFuel?.call(_totalFuel);
  }

  void _showAddAircraftDialog() {
    final nameCtrl = TextEditingController();
    final totalCtrl = TextEditingController();
    final centerCtrl = TextEditingController();
    final lInnerCtrl = TextEditingController();
    final rInnerCtrl = TextEditingController();
    final lOuterCtrl = TextEditingController();
    final rOuterCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Add New Aircraft Profile',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter the maximum fuel capacity for each tank.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),
                _buildTextField('Aircraft Name', nameCtrl, isNumber: false),
                _buildTextField('Total Fuel Max', totalCtrl),
                _buildTextField('Center Tank Max', centerCtrl),
                _buildTextField('Left Inner Max', lInnerCtrl),
                _buildTextField('Right Inner Max', rInnerCtrl),
                _buildTextField('Left Outer Max', lOuterCtrl),
                _buildTextField('Right Outer Max', rOuterCtrl),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6)),
              onPressed: () {
                if (nameCtrl.text.isEmpty ||
                    totalCtrl.text.isEmpty ||
                    centerCtrl.text.isEmpty ||
                    lInnerCtrl.text.isEmpty ||
                    rInnerCtrl.text.isEmpty ||
                    lOuterCtrl.text.isEmpty ||
                    rOuterCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields!')));
                  return;
                }

                final newProfile = {
                  'name': nameCtrl.text,
                  'totalMax': double.tryParse(totalCtrl.text) ?? 0.0,
                  'centerMax': double.tryParse(centerCtrl.text) ?? 0.0,
                  'lInnerMax': double.tryParse(lInnerCtrl.text) ?? 0.0,
                  'rInnerMax': double.tryParse(rInnerCtrl.text) ?? 0.0,
                  'lOuterMax': double.tryParse(lOuterCtrl.text) ?? 0.0,
                  'rOuterMax': double.tryParse(rOuterCtrl.text) ?? 0.0,
                };

                setState(() {
                  _profiles.add(newProfile);
                  _switchProfile(newProfile);
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Aircraft profile saved successfully!'),
                  backgroundColor: Colors.green,
                ));
              },
              child: const Text('Save Profile'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF3B82F6))),
        ),
      ),
    );
  }

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

  double _getStepSize(String tank, double max) {
    if (_currentProfile['name'] == 'A320 (Default)') {
      switch (tank) {
        case 'total':
          return 74.5;
        case 'center':
          return 11.5;
        case 'inner':
          return 25.8;
        case 'outer':
          return 3.5;
        default:
          return 1.0;
      }
    }
    return (max / 150).clamp(1.0, 100.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 850;

        Widget leftPart = Container(
          margin: EdgeInsets.only(
              left: 16,
              right: isMobile ? 16 : 8,
              bottom: isMobile ? 8 : 16,
              top: 0),
          decoration: BoxDecoration(
            color: const Color(0xFF131B26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A3A52)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.water_drop, color: Color(0xFF3B82F6), size: 16),
                    SizedBox(width: 8),
                    Text("FUEL OVERVIEW",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ],
                ),
              ),
              Expanded(
                child: _buildVisualizer(isMobile),
              ),
            ],
          ),
        );

        Widget rightPart = Container(
          margin: EdgeInsets.only(
              right: 16,
              left: isMobile ? 16 : 8,
              bottom: 16,
              top: isMobile ? 8 : 0),
          decoration: BoxDecoration(
            color: const Color(0xFF131B26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A3A52)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.tune, color: Color(0xFF3B82F6), size: 16),
                    SizedBox(width: 8),
                    Text("FUEL CONTROLS",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildControlCard(
                          'TOTAL FUEL',
                          _totalFuel,
                          _currentProfile['totalMax'],
                          _getStepSize('total', _currentProfile['totalMax']),
                          (v) => _onTotalFuelChanged(v)),
                      _buildControlCard(
                          'CENTER TANK',
                          _centerFuel,
                          _currentProfile['centerMax'],
                          _getStepSize('center', _currentProfile['centerMax']),
                          (v) => _onIndividualTankChanged('center', v)),
                      _buildControlCard(
                          'L INNER TANK',
                          _lInnerFuel,
                          _currentProfile['lInnerMax'],
                          _getStepSize('inner', _currentProfile['lInnerMax']),
                          (v) => _onIndividualTankChanged('lInner', v)),
                      _buildControlCard(
                          'R INNER TANK',
                          _rInnerFuel,
                          _currentProfile['rInnerMax'],
                          _getStepSize('inner', _currentProfile['rInnerMax']),
                          (v) => _onIndividualTankChanged('rInner', v)),
                      _buildControlCard(
                          'L OUTER TANK',
                          _lOuterFuel,
                          _currentProfile['lOuterMax'],
                          _getStepSize('outer', _currentProfile['lOuterMax']),
                          (v) => _onIndividualTankChanged('lOuter', v)),
                      _buildControlCard(
                          'R OUTER TANK',
                          _rOuterFuel,
                          _currentProfile['rOuterMax'],
                          _getStepSize('outer', _currentProfile['rOuterMax']),
                          (v) => _onIndividualTankChanged('rOuter', v)),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

        return Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? double.infinity,
          color: const Color(0xFF0B111A),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.airplanemode_active,
                                color: Color(0xFF3B82F6)),
                            const SizedBox(width: 12),
                            DropdownButton<String>(
                              value: _currentProfile['name'],
                              dropdownColor: const Color(0xFF1E293B),
                              underline: const SizedBox(),
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.white),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              items: _profiles.map((profile) {
                                return DropdownMenuItem<String>(
                                  value: profile['name'],
                                  child: Text(profile['name']),
                                );
                              }).toList(),
                              onChanged: (String? newName) {
                                if (newName != null) {
                                  final selected = _profiles
                                      .firstWhere((p) => p['name'] == newName);
                                  _switchProfile(selected);
                                }
                              },
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: _showAddAircraftDialog,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: isMobile
                        ? Column(
                            children: [
                              Expanded(flex: 5, child: leftPart),
                              Expanded(flex: 6, child: rightPart),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(flex: 5, child: leftPart),
                              Expanded(flex: 6, child: rightPart),
                            ],
                          ),
                  ),
                ],
              ),
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
        );
      },
    );
  }

  Widget _buildVisualizer(bool isMobile) {
    // تم تكبير البوكسات بشكل كبير جداً للموبايل فقط (2.15 بدلاً من 1.95)
    // وحجم الآيباد (1.15) لم يُمس
    double scaleFactor = isMobile ? 2.15 : 1.15;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 620,
            height: 900,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Transform.scale(
                    scale: isMobile ? 1.10 : 1.05,
                    child: CachedNetworkImage(
                      imageUrl:
                          'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/998DE208-FA35-4469-9A41-8631CAB9F32A.png',
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF3B82F6))),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: CustomPaint(
                    painter: ConnectionLinesPainter(isMobile: isMobile),
                  ),
                ),

                // تعديلات الموبايل: البوكسات في الزوايا الفارغة بعيداً عن الطيارة تماماً
                // L OUTER TANK - أقصى اليسار في الفراغ
                _buildVisualTag(
                    isMobile
                        ? const Alignment(-1.9, -0.30)
                        : const Alignment(-0.95, -0.27),
                    'L OUTER TANK',
                    _lOuterFuel,
                    _currentProfile['lOuterMax'],
                    scale: scaleFactor),

                // L INNER TANK - أقصى أعلى اليسار في الفراغ
                _buildVisualTag(
                    isMobile
                        ? const Alignment(-1.1, -0.98)
                        : const Alignment(-0.54, -0.55),
                    'L INNER TANK',
                    _lInnerFuel,
                    _currentProfile['lInnerMax'],
                    scale: scaleFactor),

                // CENTER TANK - أسفل أقصى اليمين بعيداً عن الطائرة
                _buildVisualTag(
                    isMobile
                        ? const Alignment(1.0, 0.4)
                        : const Alignment(0.48, 0.28),
                    'CENTER TANK',
                    _centerFuel,
                    _currentProfile['centerMax'],
                    scale: scaleFactor),

                // R INNER TANK - أقصى أعلى اليمين في الفراغ
                _buildVisualTag(
                    isMobile
                        ? const Alignment(1.1, -0.98)
                        : const Alignment(0.54, -0.55),
                    'R INNER TANK',
                    _rInnerFuel,
                    _currentProfile['rInnerMax'],
                    scale: scaleFactor),

                // R OUTER TANK - أقصى اليمين في الفراغ
                _buildVisualTag(
                    isMobile
                        ? const Alignment(1.9, -0.30)
                        : const Alignment(0.95, -0.27),
                    'R OUTER TANK',
                    _rOuterFuel,
                    _currentProfile['rOuterMax'],
                    scale: scaleFactor),

                // TOTAL FUEL - أقصى أسفل اليسار بالزاوية تماماً
                _buildVisualTag(
                    isMobile
                        ? const Alignment(-2.1, 1.0)
                        : const Alignment(-0.95, 0.82),
                    'TOTAL FUEL',
                    _totalFuel,
                    _currentProfile['totalMax'],
                    isTotal: true,
                    scale: scaleFactor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualTag(
      Alignment alignment, String label, double value, double max,
      {bool isTotal = false, double scale = 1.0}) {
    double percentage = max > 0 ? (value / max) * 100 : 0;
    return Align(
      alignment: alignment,
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 7 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFF0B111A).withOpacity(0.92),
          border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.65), width: 1.2),
          borderRadius: BorderRadius.circular(8 * scale),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_gas_station,
                    color: isTotal ? Colors.white : const Color(0xFF3B82F6),
                    size: 13 * scale),
                SizedBox(width: 5 * scale),
                Text(label,
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 3 * scale),
            Text('${value.toInt()} kg',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.bold)),
            Text('(${percentage.toStringAsFixed(0)}%)',
                style: TextStyle(color: Colors.grey, fontSize: 10.5 * scale)),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard(String title, double currentValue, double maxValue,
      double stepSize, Function(double) onChanged) {
    double percentage = maxValue > 0 ? (currentValue / maxValue) * 100 : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2436),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3A52)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_gas_station,
                      color: Color(0xFF3B82F6), size: 18),
                  const SizedBox(width: 8),
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              Text(
                  '${currentValue.toInt()} kg (${percentage.toStringAsFixed(0)}%)',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF3B82F6),
              inactiveTrackColor: const Color(0xFF0B111A),
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF3B82F6).withOpacity(0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: currentValue,
              min: 0,
              max: maxValue <= 0 ? 1.0 : maxValue,
              divisions: maxValue > 0
                  ? (maxValue / stepSize).floor().clamp(1, 1000)
                  : 100,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [0, 25, 50, 75, 100].map((percent) {
              bool isActive = (percentage.round() == percent);
              return GestureDetector(
                onTap: () => onChanged(
                    (percent / 100) * (maxValue <= 0 ? 1.0 : maxValue)),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF3B82F6).withOpacity(0.2)
                        : Colors.transparent,
                    border: Border.all(
                        color: isActive
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF2A3A52)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$percent%',
                      style: TextStyle(
                          color:
                              isActive ? const Color(0xFF3B82F6) : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class ConnectionLinesPainter extends CustomPainter {
  final bool isMobile;

  ConnectionLinesPainter({required this.isMobile});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    if (isMobile) {
      // تعديل الخطوط للموبايل لتلحق بالبوكسات في الأماكن الفارغة الجديدة
      // Center Tank line
      canvas.drawLine(Offset(size.width * 0.85, size.height * 0.75),
          Offset(size.width * 0.50, size.height * 0.61), paint);
      canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.61), 3,
          paint..style = PaintingStyle.fill);

      // L Inner Tank line
      canvas.drawLine(
          Offset(size.width * 0.15, size.height * 0.10),
          Offset(size.width * 0.35, size.height * 0.52),
          paint..style = PaintingStyle.stroke);
      canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.52), 3,
          paint..style = PaintingStyle.fill);

      // R Inner Tank line
      canvas.drawLine(
          Offset(size.width * 0.85, size.height * 0.10),
          Offset(size.width * 0.65, size.height * 0.52),
          paint..style = PaintingStyle.stroke);
      canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.52), 3,
          paint..style = PaintingStyle.fill);

      // L Outer Tank line
      canvas.drawLine(
          Offset(size.width * 0.05, size.height * 0.35),
          Offset(size.width * 0.16, size.height * 0.55),
          paint..style = PaintingStyle.stroke);
      canvas.drawCircle(Offset(size.width * 0.16, size.height * 0.55), 3,
          paint..style = PaintingStyle.fill);

      // R Outer Tank line
      canvas.drawLine(
          Offset(size.width * 0.95, size.height * 0.35),
          Offset(size.width * 0.84, size.height * 0.55),
          paint..style = PaintingStyle.stroke);
      canvas.drawCircle(Offset(size.width * 0.84, size.height * 0.55), 3,
          paint..style = PaintingStyle.fill);
    } else {
      // Tablet / iPad lines - THESE REMAIN UNTOUCHED AS REQUESTED
      // Center Tank line
      canvas.drawLine(Offset(size.width * 0.73, size.height * 0.62),
          Offset(size.width * 0.50, size.height * 0.60), paint);
      canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.60), 3,
          paint..style = PaintingStyle.fill);

      // L Inner Tank line
      canvas.drawLine(
          Offset(size.width * 0.24, size.height * 0.26),
          Offset(size.width * 0.36, size.height * 0.52),
          paint..style = PaintingStyle.stroke);
      canvas.drawCircle(Offset(size.width * 0.36, size.height * 0.52), 3,
          paint..style = PaintingStyle.fill);

      // R Inner Tank line
      canvas.drawLine(
          Offset(size.width * 0.76, size.height * 0.26),
          Offset(size.width * 0.64, size.height * 0.52),
          paint..style = PaintingStyle.stroke);
      canvas.drawCircle(Offset(size.width * 0.64, size.height * 0.52), 3,
          paint..style = PaintingStyle.fill);

      // L Outer Tank line
      canvas.drawLine(
          Offset(size.width * 0.11, size.height * 0.37),
          Offset(size.width * 0.17, size.height * 0.55),
          paint..style = PaintingStyle.stroke);
      canvas.drawCircle(Offset(size.width * 0.17, size.height * 0.55), 3,
          paint..style = PaintingStyle.fill);

      // R Outer Tank line
      canvas.drawLine(
          Offset(size.width * 0.89, size.height * 0.37),
          Offset(size.width * 0.83, size.height * 0.55),
          paint..style = PaintingStyle.stroke);
      canvas.drawCircle(Offset(size.width * 0.83, size.height * 0.55), 3,
          paint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
