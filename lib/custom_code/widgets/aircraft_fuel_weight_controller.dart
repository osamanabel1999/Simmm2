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

class AircraftFuelWeightController extends StatefulWidget {
  const AircraftFuelWeightController({
    Key? key,
    this.width,
    this.height,
    this.onLeftTank0,
    this.onLeftTank25,
    this.onLeftTank50,
    this.onLeftTank75,
    this.onLeftTank100,
    this.onCenterTank0,
    this.onCenterTank25,
    this.onCenterTank50,
    this.onCenterTank75,
    this.onCenterTank100,
    this.onRightTank0,
    this.onRightTank25,
    this.onRightTank50,
    this.onRightTank75,
    this.onRightTank100,
    this.onLeftSliderChanged,
    this.onCenterSliderChanged,
    this.onRightSliderChanged,
    this.onPilotWeightSubmitted,
    this.onCoPilotWeightSubmitted,
    this.onRearPassengerWeightSubmitted,
    this.onBaggageWeightSubmitted,
    this.onExtraCargoWeightSubmitted,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Future Function()? onLeftTank0;
  final Future Function()? onLeftTank25;
  final Future Function()? onLeftTank50;
  final Future Function()? onLeftTank75;
  final Future Function()? onLeftTank100;
  final Future Function()? onCenterTank0;
  final Future Function()? onCenterTank25;
  final Future Function()? onCenterTank50;
  final Future Function()? onCenterTank75;
  final Future Function()? onCenterTank100;
  final Future Function()? onRightTank0;
  final Future Function()? onRightTank25;
  final Future Function()? onRightTank50;
  final Future Function()? onRightTank75;
  final Future Function()? onRightTank100;

  // Callbacks الخاصة بالسلايدرز
  final Future Function(double leftValue)? onLeftSliderChanged;
  final Future Function(double centerValue)? onCenterSliderChanged;
  final Future Function(double rightValue)? onRightSliderChanged;

  // تم التعديل هنا لتمرير قيمة الوزن لكل محطة
  final Future Function(double weightLbs)? onPilotWeightSubmitted;
  final Future Function(double weightLbs)? onCoPilotWeightSubmitted;
  final Future Function(double weightLbs)? onRearPassengerWeightSubmitted;
  final Future Function(double weightLbs)? onBaggageWeightSubmitted;
  final Future Function(double weightLbs)? onExtraCargoWeightSubmitted;

  @override
  State<AircraftFuelWeightController> createState() =>
      _AircraftFuelWeightControllerState();
}

class _AircraftFuelWeightControllerState
    extends State<AircraftFuelWeightController> {
  double leftFuelVal = 50.0;
  double centerFuelVal = 50.0;
  double rightFuelVal = 50.0;

  final TextEditingController pilotCtrl = TextEditingController();
  final TextEditingController coPilotCtrl = TextEditingController();
  final TextEditingController rearPassCtrl = TextEditingController();
  final TextEditingController baggageCtrl = TextEditingController();
  final TextEditingController extraCargoCtrl = TextEditingController();

  final Color bgColor = const Color(0xFF1D2428);
  final Color borderColor = const Color(0xFF2E3841);
  final Color accentColor = const Color(0xFF2081FF);
  final Color iconBgColor = const Color(0xFF242B3A);
  final Color inputBgColor = const Color(0xFF161C20);

  @override
  void dispose() {
    pilotCtrl.dispose();
    coPilotCtrl.dispose();
    rearPassCtrl.dispose();
    baggageCtrl.dispose();
    extraCargoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      color: bgColor,
      padding: const EdgeInsets.all(20.0),
      // هنا الحركة الصايعة: LayoutBuilder بيقرأ عرض الشاشة ويحدد التصميم المناسب
      child: LayoutBuilder(
        builder: (context, constraints) {
          // لو الشاشة أقل من 750 بيكسل (موبايل)
          if (constraints.maxWidth < 750) {
            return _buildMobileLayout();
          }
          // لو الشاشة أكبر (آيباد) بيعرض تصميمك القديم دون أي تدخل
          return _buildTabletLayout();
        },
      ),
    );
  }

  // ==========================================
  // تصميم الآيباد الأصلي (لم يتم المساس به تماماً)
  // ==========================================
  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('FUEL TANKS'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildFuelTank(
                    title: 'Left Tank',
                    currentVal: leftFuelVal,
                    onChanged: (val) {
                      setState(() => leftFuelVal = val);
                      widget.onLeftSliderChanged?.call(val);
                    },
                    actions: [
                      widget.onLeftTank0,
                      widget.onLeftTank25,
                      widget.onLeftTank50,
                      widget.onLeftTank75,
                      widget.onLeftTank100
                    ],
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: _buildFuelTank(
                    title: 'Center Tank',
                    currentVal: centerFuelVal,
                    onChanged: (val) {
                      setState(() => centerFuelVal = val);
                      widget.onCenterSliderChanged?.call(val);
                    },
                    actions: [
                      widget.onCenterTank0,
                      widget.onCenterTank25,
                      widget.onCenterTank50,
                      widget.onCenterTank75,
                      widget.onCenterTank100
                    ],
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: _buildFuelTank(
                    title: 'Right Tank',
                    currentVal: rightFuelVal,
                    onChanged: (val) {
                      setState(() => rightFuelVal = val);
                      widget.onRightSliderChanged?.call(val);
                    },
                    actions: [
                      widget.onRightTank0,
                      widget.onRightTank25,
                      widget.onRightTank50,
                      widget.onRightTank75,
                      widget.onRightTank100
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader('FUEL STATIONS WEIGHT'),
              Row(
                children: [
                  const Text('Weight Unit',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: const Text('lbs',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('STATION / LOCATION',
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    Text('WEIGHT (LBS)',
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildWeightRow(Icons.local_police_outlined, 'Pilot / Captain',
                    pilotCtrl, widget.onPilotWeightSubmitted),
                _buildWeightRow(Icons.person_outline, 'Co-Pilot', coPilotCtrl,
                    widget.onCoPilotWeightSubmitted),
                _buildWeightRow(
                    Icons.airline_seat_recline_normal,
                    'Rear Passenger Seats',
                    rearPassCtrl,
                    widget.onRearPassengerWeightSubmitted),
                _buildWeightRow(Icons.luggage, 'Baggage Hold', baggageCtrl,
                    widget.onBaggageWeightSubmitted),
                _buildWeightRow(Icons.add, 'Extra Cargo / Additional Load',
                    extraCargoCtrl, widget.onExtraCargoWeightSubmitted,
                    isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // التصميم الجديد المخصص للموبايل فقط
  // ==========================================
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('FUEL TANKS'),
          const SizedBox(height: 16),
          // الـ Tanks بقت تحت بعضها بدل ما هي جنب بعض
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                _buildMobileFuelTank(
                  title: 'Left Tank',
                  currentVal: leftFuelVal,
                  onChanged: (val) {
                    setState(() => leftFuelVal = val);
                    widget.onLeftSliderChanged?.call(val);
                  },
                  actions: [
                    widget.onLeftTank0,
                    widget.onLeftTank25,
                    widget.onLeftTank50,
                    widget.onLeftTank75,
                    widget.onLeftTank100
                  ],
                ),
                _buildHorizontalDivider(),
                _buildMobileFuelTank(
                  title: 'Center Tank',
                  currentVal: centerFuelVal,
                  onChanged: (val) {
                    setState(() => centerFuelVal = val);
                    widget.onCenterSliderChanged?.call(val);
                  },
                  actions: [
                    widget.onCenterTank0,
                    widget.onCenterTank25,
                    widget.onCenterTank50,
                    widget.onCenterTank75,
                    widget.onCenterTank100
                  ],
                ),
                _buildHorizontalDivider(),
                _buildMobileFuelTank(
                  title: 'Right Tank',
                  currentVal: rightFuelVal,
                  onChanged: (val) {
                    setState(() => rightFuelVal = val);
                    widget.onRightSliderChanged?.call(val);
                  },
                  actions: [
                    widget.onRightTank0,
                    widget.onRightTank25,
                    widget.onRightTank50,
                    widget.onRightTank75,
                    widget.onRightTank100
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildSectionHeader('FUEL STATIONS WEIGHT')),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: const Text('Unit: lbs',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 16),
          // الأوزان بتصميم ذكي للموبايل
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                _buildMobileWeightRow(
                    Icons.local_police_outlined,
                    'Pilot / Captain',
                    pilotCtrl,
                    widget.onPilotWeightSubmitted),
                _buildMobileWeightRow(Icons.person_outline, 'Co-Pilot',
                    coPilotCtrl, widget.onCoPilotWeightSubmitted),
                _buildMobileWeightRow(
                    Icons.airline_seat_recline_normal,
                    'Rear Passenger Seats',
                    rearPassCtrl,
                    widget.onRearPassengerWeightSubmitted),
                _buildMobileWeightRow(Icons.luggage, 'Baggage Hold',
                    baggageCtrl, widget.onBaggageWeightSubmitted),
                _buildMobileWeightRow(Icons.add, 'Extra Cargo', extraCargoCtrl,
                    widget.onExtraCargoWeightSubmitted,
                    isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Helper Widgets
  // ==========================================

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF5A66E9),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  // الفاصل الطولي للآيباد (الأصلي)
  Widget _buildVerticalDivider() {
    return Container(
      height: 150,
      width: 1,
      color: borderColor,
      margin: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  // الفاصل العرضي للموبايل
  Widget _buildHorizontalDivider() {
    return Container(
      height: 1,
      width: double.infinity,
      color: borderColor,
      margin: const EdgeInsets.symmetric(vertical: 24),
    );
  }

  // Tank الآيباد (الأصلي)
  Widget _buildFuelTank({
    required String title,
    required double currentVal,
    required Function(double) onChanged,
    required List<Future Function()?> actions,
  }) {
    List<double> percentages = [0, 25, 50, 75, 100];
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: iconBgColor,
          radius: 28,
          child: Icon(Icons.airplanemode_active, color: accentColor, size: 28),
        ),
        const SizedBox(height: 16),
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            double pVal = percentages[index];
            bool isActive = currentVal == pVal;
            return InkWell(
              onTap: () {
                onChanged(pVal);
                actions[index]?.call();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: isActive ? accentColor : borderColor),
                ),
                child: Text('${pVal.toInt()}%',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[400],
                      fontSize: 12,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    )),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: accentColor,
            inactiveTrackColor: iconBgColor,
            thumbColor: accentColor,
            trackHeight: 6,
            tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 3),
            activeTickMarkColor: Colors.transparent,
            inactiveTickMarkColor: borderColor,
          ),
          child: Slider(
            value: currentVal,
            min: 0,
            max: 100,
            divisions: 4,
            onChanged: onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text('100%',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // Tank الموبايل (احترافي عشان ميحصلش Overflow في الزراير)
  Widget _buildMobileFuelTank({
    required String title,
    required double currentVal,
    required Function(double) onChanged,
    required List<Future Function()?> actions,
  }) {
    List<double> percentages = [0, 25, 50, 75, 100];
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: iconBgColor,
              radius: 20,
              child:
                  Icon(Icons.airplanemode_active, color: accentColor, size: 20),
            ),
            const SizedBox(width: 16),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        // استخدمت Wrap هنا عشان لو الشاشة صغيرة جداً الأزرار تنزل سطر جديد بشياكة
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(5, (index) {
            double pVal = percentages[index];
            bool isActive = currentVal == pVal;
            return InkWell(
              onTap: () {
                onChanged(pVal);
                actions[index]?.call();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: isActive ? accentColor : borderColor),
                ),
                child: Text('${pVal.toInt()}%',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[400],
                      fontSize: 12,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    )),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: accentColor,
            inactiveTrackColor: iconBgColor,
            thumbColor: accentColor,
            trackHeight: 6,
            tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 3),
            activeTickMarkColor: Colors.transparent,
            inactiveTickMarkColor: borderColor,
          ),
          child: Slider(
            value: currentVal,
            min: 0,
            max: 100,
            divisions: 4,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // Weight Row الآيباد (الأصلي)
  Widget _buildWeightRow(
      IconData icon,
      String title,
      TextEditingController controller,
      Future Function(double weightLbs)? actionCallback,
      {bool isLast = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconBgColor,
            radius: 20,
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          Container(
            width: 150,
            height: 48,
            decoration: BoxDecoration(
              color: inputBgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                hintText: 'Enter weight',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: (val) {
                if (actionCallback != null) {
                  double weight = double.tryParse(val) ?? 0.0;
                  actionCallback(weight);
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          const Text('lbs',
              style: TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  // Weight Row الموبايل
  Widget _buildMobileWeightRow(
      IconData icon,
      String title,
      TextEditingController controller,
      Future Function(double weightLbs)? actionCallback,
      {bool isLast = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        color: iconBgColor.withOpacity(0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: iconBgColor,
                radius: 18,
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: inputBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Enter weight',
                      hintStyle:
                          TextStyle(color: Colors.grey[600], fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: (val) {
                      if (actionCallback != null) {
                        double weight = double.tryParse(val) ?? 0.0;
                        actionCallback(weight);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text('lbs',
                  style: TextStyle(color: Colors.white54, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
