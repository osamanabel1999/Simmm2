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

class FuelLoadEFBmsfs extends StatefulWidget {
  const FuelLoadEFBmsfs({
    Key? key,
    this.width,
    this.height,
    this.updateTotalFuel,
    this.updateCenterFuel,
    this.updateLWingFuel,
    this.updateRWingFuel,
    // --- NEW WEIGHT PARAMETERS ---
    this.updatePilotWeight,
    this.updateCoPilotWeight,
    this.updateRearPaxWeight,
    this.updateBaggageWeight,
    this.updateExtraCargoWeight,
  }) : super(key: key);

  final double? width;
  final double? height;

  final Future Function(double fuelValue)? updateTotalFuel;
  final Future Function(double fuelValue)? updateCenterFuel;
  final Future Function(double fuelValue)? updateLWingFuel;
  final Future Function(double fuelValue)? updateRWingFuel;

  // --- NEW WEIGHT CALLBACKS ---
  final Future Function(double weightValue)? updatePilotWeight;
  final Future Function(double weightValue)? updateCoPilotWeight;
  final Future Function(double weightValue)? updateRearPaxWeight;
  final Future Function(double weightValue)? updateBaggageWeight;
  final Future Function(double weightValue)? updateExtraCargoWeight;

  @override
  _FuelLoadEFBmsfsState createState() => _FuelLoadEFBmsfsState();
}

class _FuelLoadEFBmsfsState extends State<FuelLoadEFBmsfs> {
  bool _isLoading = true;

  List<Map<String, dynamic>> _profiles = [];
  Map<String, dynamic> _currentProfile = {};

  // Fuel Values (Merged Tanks)
  double _totalFuel = 0;
  double _centerFuel = 0;
  double _lWingFuel = 0;
  double _rWingFuel = 0;

  // Default A320 with merged wing capacities (Inner + Outer)
  final Map<String, dynamic> _defaultA320 = {
    'name': 'A320 (Default)',
    'totalMax': 18676.0,
    'centerMax': 6479.0,
    'lWingMax': 6122.0, // 5430 + 692
    'rWingMax': 6122.0, // 5430 + 692
  };

  // --- NEW WEIGHT CONTROLLERS ---
  final TextEditingController _pilotCtrl = TextEditingController();
  final TextEditingController _coPilotCtrl = TextEditingController();
  final TextEditingController _rearPaxCtrl = TextEditingController();
  final TextEditingController _baggageCtrl = TextEditingController();
  final TextEditingController _cargoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    // التخلص من الكنترولرز للحفاظ على الأداء ومنع استهلاك الذاكرة
    _pilotCtrl.dispose();
    _coPilotCtrl.dispose();
    _rearPaxCtrl.dispose();
    _baggageCtrl.dispose();
    _cargoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getStringList('aircraft_profiles_msfs');
    final lastSelected = prefs.getString('last_selected_aircraft_msfs');

    _profiles = [_defaultA320];

    if (profilesJson != null) {
      for (var jsonStr in profilesJson) {
        try {
          final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
          decoded['totalMax'] = (decoded['totalMax'] as num).toDouble();
          decoded['centerMax'] = (decoded['centerMax'] as num).toDouble();
          decoded['lWingMax'] = (decoded['lWingMax'] as num).toDouble();
          decoded['rWingMax'] = (decoded['rWingMax'] as num).toDouble();
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

    await prefs.setStringList('aircraft_profiles_msfs', profilesJson);
    await prefs.setString(
        'last_selected_aircraft_msfs', _currentProfile['name']);
  }

  void _setInitialValues(Map<String, dynamic> profile) {
    if (profile['name'] == 'A320 (Default)') {
      _centerFuel = 3200;
      _lWingFuel = 2800;
      _rWingFuel = 2800;
    } else {
      _centerFuel = profile['centerMax'] / 2;
      _lWingFuel = profile['lWingMax'] / 2;
      _rWingFuel = profile['rWingMax'] / 2;
    }
    _totalFuel = _centerFuel + _lWingFuel + _rWingFuel;
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
          _currentProfile['lWingMax'] +
          _currentProfile['rWingMax'];

      if (sumMax > 0) {
        double ratio = newTotal / sumMax;
        _centerFuel = _currentProfile['centerMax'] * ratio;
        _lWingFuel = _currentProfile['lWingMax'] * ratio;
        _rWingFuel = _currentProfile['rWingMax'] * ratio;
      }
    });

    widget.updateTotalFuel?.call(_totalFuel);
    widget.updateCenterFuel?.call(_centerFuel);
    widget.updateLWingFuel?.call(_lWingFuel);
    widget.updateRWingFuel?.call(_rWingFuel);
  }

  void _onIndividualTankChanged(String tankType, double newVal) {
    setState(() {
      if (tankType == 'center') _centerFuel = newVal;
      if (tankType == 'lWing') _lWingFuel = newVal;
      if (tankType == 'rWing') _rWingFuel = newVal;

      _totalFuel = _centerFuel + _lWingFuel + _rWingFuel;
    });

    if (tankType == 'center') widget.updateCenterFuel?.call(_centerFuel);
    if (tankType == 'lWing') widget.updateLWingFuel?.call(_lWingFuel);
    if (tankType == 'rWing') widget.updateRWingFuel?.call(_rWingFuel);

    widget.updateTotalFuel?.call(_totalFuel);
  }

  void _showAddAircraftDialog() {
    final nameCtrl = TextEditingController();
    final totalCtrl = TextEditingController();
    final centerCtrl = TextEditingController();
    final lWingCtrl = TextEditingController();
    final rWingCtrl = TextEditingController();

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
                  'Enter the maximum fuel capacity for each main tank.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),
                _buildTextField('Aircraft Name', nameCtrl, isNumber: false),
                _buildTextField('Total Fuel Max', totalCtrl),
                _buildTextField('Center Tank Max', centerCtrl),
                _buildTextField('Left Wing Tank Max', lWingCtrl),
                _buildTextField('Right Wing Tank Max', rWingCtrl),
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
                    lWingCtrl.text.isEmpty ||
                    rWingCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields!')));
                  return;
                }

                final newProfile = {
                  'name': nameCtrl.text,
                  'totalMax': double.tryParse(totalCtrl.text) ?? 0.0,
                  'centerMax': double.tryParse(centerCtrl.text) ?? 0.0,
                  'lWingMax': double.tryParse(lWingCtrl.text) ?? 0.0,
                  'rWingMax': double.tryParse(rWingCtrl.text) ?? 0.0,
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
    if (_currentProfile['name'] == 'A320') {
      switch (tank) {
        case 'total':
          return 74.5;
        case 'center':
          return 11.5;
        case 'wing':
          return 29.3;
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
                          'LEFT WING TANK',
                          _lWingFuel,
                          _currentProfile['lWingMax'],
                          _getStepSize('wing', _currentProfile['lWingMax']),
                          (v) => _onIndividualTankChanged('lWing', v)),
                      _buildControlCard(
                          'RIGHT WING TANK',
                          _rWingFuel,
                          _currentProfile['rWingMax'],
                          _getStepSize('wing', _currentProfile['rWingMax']),
                          (v) => _onIndividualTankChanged('rWing', v)),
                      const SizedBox(height: 16),

                      // --- NEW WEIGHT CONTROLS SECTION ---
                      _buildWeightSection(),

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

  // --- NEW CUSTOM WIDGET FOR WEIGHTS ---
  Widget _buildWeightSection() {
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
          const Row(
            children: [
              Icon(Icons.monitor_weight_outlined,
                  color: Color(0xFF3B82F6), size: 18),
              SizedBox(width: 8),
              Text("PAYLOAD & WEIGHT",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          // Adding the 5 inputs dynamically with callbacks
          _buildWeightInputField("Pilot", _pilotCtrl, widget.updatePilotWeight),
          _buildWeightInputField(
              "Co-Pilot", _coPilotCtrl, widget.updateCoPilotWeight),
          _buildWeightInputField("Rear Passengers Seats", _rearPaxCtrl,
              widget.updateRearPaxWeight),
          _buildWeightInputField(
              "Baggage Holds", _baggageCtrl, widget.updateBaggageWeight),
          _buildWeightInputField(
              "Extra Cargo", _cargoCtrl, widget.updateExtraCargoWeight,
              isLast: true),
        ],
      ),
    );
  }

  // --- HELPER METHOD TO BUILD EACH WEIGHT FIELD PREVENTING OVERFLOW ---
  Widget _buildWeightInputField(String title, TextEditingController controller,
      Future Function(double)? callback,
      {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 48, // ارتفاع احترافي وموحد للايباد والموبايل
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                filled: true,
                fillColor: const Color(0xFF0B111A), // لون غامق ليتماشى مع الثيم
                // إضافة كلمة lbs بشكل احترافي وصغير جدا بجانب الرقم
                suffixIcon: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 12.0),
                      child: Text('lbs',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.normal)),
                    ),
                  ],
                ),
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2A3A52)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                ),
              ),
              // يتم إرسال الرقم فورا بمجرد كتابته للمحاكي
              onChanged: (val) {
                double? parsedValue = double.tryParse(val);
                if (parsedValue != null && callback != null) {
                  callback(parsedValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualizer(bool isMobile) {
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
                      // الرابط الصحيح الذي أرسلته أنت
                      imageUrl:
                          'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/1410CF20-EA1F-4FCB-A35B-E84FFF676436.png',
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

                // L WING TANK
                _buildVisualTag(
                    isMobile
                        ? const Alignment(-1.5, -0.65)
                        : const Alignment(-0.9, -0.40),
                    'L WING TANK',
                    _lWingFuel,
                    _currentProfile['lWingMax'],
                    scale: scaleFactor),

                // CENTER TANK
                _buildVisualTag(
                    isMobile
                        ? const Alignment(1.0, 0.4)
                        : const Alignment(0.52, 0.26),
                    'CENTER TANK',
                    _centerFuel,
                    _currentProfile['centerMax'],
                    scale: scaleFactor),

                // R WING TANK
                _buildVisualTag(
                    isMobile
                        ? const Alignment(1.5, -0.65)
                        : const Alignment(0.9, -0.40),
                    'R WING TANK',
                    _rWingFuel,
                    _currentProfile['rWingMax'],
                    scale: scaleFactor),

                // TOTAL FUEL
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
      // Center Tank line
      canvas.drawLine(Offset(size.width * 0.85, size.height * 0.75),
          Offset(size.width * 0.50, size.height * 0.55), paint);
      canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.55), 3,
          paint..style = PaintingStyle.fill);

      // L Wing Tank line
      canvas.drawLine(
          Offset(size.width * 0.15, size.height * 0.18),
          Offset(size.width * 0.30, size.height * 0.48),
          paint..style = PaintingStyle.stroke);
      canvas.drawCircle(Offset(size.width * 0.30, size.height * 0.48), 3,
          paint..style = PaintingStyle.fill);

      // R Wing Tank line
      canvas.drawLine(
          Offset(size.width * 0.85, size.height * 0.18),
          Offset(size.width * 0.70, size.height * 0.48),
          paint..style = PaintingStyle.stroke);
      canvas.drawCircle(Offset(size.width * 0.70, size.height * 0.48), 3,
          paint..style = PaintingStyle.fill);
    } else {
      // Center Tank line
      canvas.drawLine(Offset(size.width * 0.73, size.height * 0.62),
          Offset(size.width * 0.50, size.height * 0.55), paint);
      canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.55), 3,
          paint..style = PaintingStyle.fill);

      // L Wing Tank line
      canvas.drawLine(
          Offset(size.width * 0.20, size.height * 0.32),
          Offset(size.width * 0.32, size.height * 0.48),
          paint..style = PaintingStyle.stroke);
      canvas.drawCircle(Offset(size.width * 0.32, size.height * 0.48), 3,
          paint..style = PaintingStyle.fill);

      // R Wing Tank line
      canvas.drawLine(
          Offset(size.width * 0.80, size.height * 0.32),
          Offset(size.width * 0.68, size.height * 0.48),
          paint..style = PaintingStyle.stroke);
      canvas.drawCircle(Offset(size.width * 0.68, size.height * 0.48), 3,
          paint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
