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

import 'package:shared_preferences/shared_preferences.dart';

class ChecklistEFBmsfs extends StatefulWidget {
  const ChecklistEFBmsfs({
    Key? key,
    this.width,
    this.height,
    // A320 Callbacks (11)
    this.onA320CockpitPrep,
    this.onA320BeforeStart,
    this.onA320AfterStart,
    this.onA320Taxi,
    this.onA320Lineup,
    this.onA320DepartureChange,
    this.onA320Approach,
    this.onA320Landing,
    this.onA320AfterLanding,
    this.onA320Parking,
    this.onA320SecuringAircraft,
    // B737 Callbacks (9)
    this.onB737Preflight,
    this.onB737BeforeStart,
    this.onB737BeforeTaxi,
    this.onB737BeforeTakeoff,
    this.onB737AfterTakeoff,
    this.onB737Descent,
    this.onB737Approach,
    this.onB737Landing,
    this.onB737Parking,
  }) : super(key: key);

  final double? width;
  final double? height;

  final Future Function()? onA320CockpitPrep;
  final Future Function()? onA320BeforeStart;
  final Future Function()? onA320AfterStart;
  final Future Function()? onA320Taxi;
  final Future Function()? onA320Lineup;
  final Future Function()? onA320DepartureChange;
  final Future Function()? onA320Approach;
  final Future Function()? onA320Landing;
  final Future Function()? onA320AfterLanding;
  final Future Function()? onA320Parking;
  final Future Function()? onA320SecuringAircraft;

  final Future Function()? onB737Preflight;
  final Future Function()? onB737BeforeStart;
  final Future Function()? onB737BeforeTaxi;
  final Future Function()? onB737BeforeTakeoff;
  final Future Function()? onB737AfterTakeoff;
  final Future Function()? onB737Descent;
  final Future Function()? onB737Approach;
  final Future Function()? onB737Landing;
  final Future Function()? onB737Parking;

  @override
  _ChecklistEFBmsfsState createState() => _ChecklistEFBmsfsState();
}

class _ChecklistEFBmsfsState extends State<ChecklistEFBmsfs> {
  String _selectedAircraft = 'A320';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedAircraft = prefs.getString('last_checklist_aircraft') ?? 'A320';
      _isLoading = false;
    });
  }

  Future<void> _savePreference(String aircraft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_checklist_aircraft', aircraft);
  }

  void _switchAircraft(String aircraft) {
    if (_selectedAircraft != aircraft) {
      setState(() {
        _selectedAircraft = aircraft;
      });
      _savePreference(aircraft);
    }
  }

  // --- A320 CHECKLIST DATA EXACTLY FROM IMAGE ---
  final List<Map<String, dynamic>> _a320Checklists = [
    {
      'title': 'COCKPIT PREPARATION',
      'action': 'onA320CockpitPrep',
      'items': [
        {'item': 'GEAR PINS & COVERS', 'value': 'REMOVED'},
        {'item': 'FUEL QUANTITY', 'value': 'CHECKED'},
        {'item': 'SEAT BELTS', 'value': 'ON'},
        {'item': 'ADIRS', 'value': 'NAV'},
        {'item': 'BARO REF', 'value': 'SET'},
      ]
    },
    {
      'title': 'BEFORE START',
      'action': 'onA320BeforeStart',
      'items': [
        {'item': 'PARKING BRAKE', 'value': 'SET'},
        {'item': 'T.O SPEEDS & THRUST', 'value': 'CHECKED'},
        {'item': 'WINDOWS', 'value': 'CLOSED'},
        {'item': 'BEACON', 'value': 'ON'},
      ]
    },
    {
      'title': 'AFTER START',
      'action': 'onA320AfterStart',
      'items': [
        {'item': 'ANTI ICE', 'value': 'CHECKED'},
        {'item': 'ECAM STATUS', 'value': 'CHECKED'},
        {'item': 'PITCH TRIM', 'value': 'SET'},
        {'item': 'RUDDER TRIM', 'value': 'NEUTRAL'},
      ]
    },
    {
      'title': 'TAXI',
      'action': 'onA320Taxi',
      'items': [
        {'item': 'FLIGHT CONTROL', 'value': 'CHECKED'},
        {'item': 'FLAPS SETTING', 'value': 'SET'},
        {'item': 'RADAR & PWS', 'value': 'ON AND AUTO'},
        {'item': 'ENG MODE SEL', 'value': 'NORM'},
        {'item': 'ECAM MEMO', 'value': 'NO BLUE'},
        {'item': ' - AUTO BRK MAX', 'value': ''},
        {'item': ' - SIGNS ON', 'value': ''},
        {'item': ' - CABIN READY (◄)', 'value': ''},
        {'item': ' - FLAPS T.O', 'value': ''},
        {'item': ' - T.O CONFIG NORM', 'value': ''},
      ]
    },
    {
      'title': 'LINEUP',
      'action': 'onA320Lineup',
      'items': [
        {'item': 'T.O RWY', 'value': 'CHECKED'},
        {'item': 'TCAS', 'value': 'TA/RA'},
        {'item': 'PACK 1 & 2', 'value': 'CHECKED'},
      ]
    },
    {
      'title': 'DEPARTURE CHANGE',
      'action': 'onA320DepartureChange',
      'items': [
        {'item': 'RWY & SID', 'value': 'CHECKED'},
        {'item': 'FLAPS SETTING', 'value': 'SET'},
        {'item': 'T.O SPEEDS & THRUST', 'value': 'CHECKED'},
        {'item': 'FCU ALT', 'value': 'SET'},
      ]
    },
    {
      'title': 'APPROACH',
      'action': 'onA320Approach',
      'items': [
        {'item': 'BARO REF', 'value': 'SET'},
        {'item': 'SEAT BELTS', 'value': 'ON'},
        {'item': 'MINIMUM', 'value': 'CHECKED'},
        {'item': 'AUTO BRAKE', 'value': 'SET'},
        {'item': 'ENG MODE SEL', 'value': 'NORM'},
      ]
    },
    {
      'title': 'LANDING',
      'action': 'onA320Landing',
      'items': [
        {'item': 'GO-AROUND ALT', 'value': 'SET'},
        {'item': 'CABIN CREW', 'value': 'ADVISED'},
        {'item': 'ECAM MEMO', 'value': 'NO BLUE'},
        {'item': ' - LDG GEAR DN', 'value': ''},
        {'item': ' - SIGNS ON', 'value': ''},
        {'item': ' - CABIN READY (◄)', 'value': ''},
        {'item': ' - SPLRS ARM', 'value': ''},
        {'item': ' - FLAPS SET', 'value': ''},
      ]
    },
    {
      'title': 'AFTER LANDING',
      'action': 'onA320AfterLanding',
      'items': [
        {'item': 'RADAR & PWS', 'value': 'OFF'},
      ]
    },
    {
      'title': 'PARKING',
      'action': 'onA320Parking',
      'items': [
        {'item': 'PARK BRK or CHOCKS', 'value': 'SET'},
        {'item': 'ENGINES', 'value': 'OFF'},
        {'item': 'WING LIGHTS', 'value': 'OFF'},
        {'item': 'FUEL PUMPS', 'value': 'OFF'},
      ]
    },
    {
      'title': 'SECURING THE AIRCRAFT',
      'action': 'onA320SecuringAircraft',
      'items': [
        {'item': 'OXYGEN', 'value': 'OFF'},
        {'item': 'EMER EXIT LT', 'value': 'OFF'},
        {'item': 'EFBs', 'value': 'OFF'},
        {'item': 'BATTERIES', 'value': 'OFF'},
      ]
    },
  ];

  // --- B737 CHECKLIST DATA EXACTLY FROM IMAGE ---
  final List<Map<String, dynamic>> _b737Checklists = [
    {
      'title': 'PREFLIGHT',
      'action': 'onB737Preflight',
      'items': [
        {'item': 'OXYGEN', 'value': 'TESTED 100%'},
        {'item': 'ACARS', 'value': 'INITIALISED'},
        {'item': 'NAV TRANSFER SWITCHES', 'value': 'NORMAL'},
        {'item': 'YAW DAMPER', 'value': 'ON'},
        {'item': 'EMERGENCY EXIT LIGHTS', 'value': 'ARMED'},
        {'item': 'WINDOW HEAT', 'value': 'ON'},
        {'item': 'PRESS MODE SELECTOR', 'value': 'AUTO'},
        {'item': 'FLIGHT INSTRUMENTS', 'value': 'HDG ( ) ALT ( )'},
        {'item': 'GPS', 'value': 'SET NAV'},
        {'item': 'PARKING BRAKE', 'value': 'SET'},
        {'item': 'ENG START LEVERS', 'value': 'CUTOFF'},
        {'item': 'VOICE RECORDER', 'value': 'ON'},
      ]
    },
    {
      'title': 'BEFORE START',
      'action': 'onB737BeforeStart',
      'items': [
        {'item': 'FLIGHT DECK DOOR', 'value': 'CLOSED & LOCKED'},
        {'item': 'DOORS', 'value': 'CLOSED'},
        {'item': 'FUEL', 'value': '( ) KG/LBS, PUMPS ON'},
        {'item': 'PAX SIGNS', 'value': 'ON'},
        {'item': 'WINDOWS', 'value': 'CLOSED & LOCKED'},
        {'item': 'MCP', 'value': '(V2_HDG_ALT_)'},
        {'item': 'TAKEOFF SPEEDS', 'value': '(V1_VR_V2_)'},
        {'item': 'CDU PREFLIGHT', 'value': 'COMPLETED'},
        {'item': 'RUDDER & AILERON TRIM', 'value': 'FREE & ZERO'},
        {'item': 'TAXI & TAKEOFF BRIEFING', 'value': 'CONFIRMED'},
        {'item': 'ANTI COLLISION LIGHTS', 'value': 'ON'},
      ]
    },
    {
      'title': 'BEFORE TAXI',
      'action': 'onB737BeforeTaxi',
      'items': [
        {'item': 'GENERATORS', 'value': 'ON'},
        {'item': 'PROBE HEAT', 'value': 'ON'},
        {'item': 'ANTI ICE', 'value': 'AS RQRD'},
        {'item': 'ISOLATION VALVE', 'value': 'AUTO CLOSED'},
        {'item': 'ENG START SWITCHES', 'value': 'CONT'},
        {'item': 'PRESSURIZATION', 'value': 'PACKS ON, FLT AUTO'},
        {'item': 'AUTOTHROTTLE', 'value': 'ARMED'},
        {'item': 'RECALL', 'value': 'CHECKED'},
        {'item': 'AUTOBRAKE', 'value': 'RTO'},
        {'item': 'ENG START LEVERS', 'value': 'IDLE DETENT'},
        {'item': 'FLIGHT CONTROLS', 'value': 'CHECKED'},
        {'item': 'GROUND EQUIPMENT', 'value': 'CLEAR, HAND SIG'},
      ]
    },
    {
      'title': 'BEFORE TAKEOFF',
      'action': 'onB737BeforeTakeoff',
      'items': [
        {'item': 'FLAPS', 'value': '( ) GRN LIGHT'},
        {'item': 'STABILIZER TRIM', 'value': '( ) UNITS'},
        {'item': 'STROBE LIGHTS', 'value': 'ON'},
      ]
    },
    {
      'title': 'AFTER TAKEOFF',
      'action': 'onB737AfterTakeoff',
      'items': [
        {'item': 'ENGINE BLEEDS', 'value': 'ON'},
        {'item': 'PACKS', 'value': 'AUTO'},
        {'item': 'LANDING GEAR', 'value': 'UP & OFF'},
        {'item': 'FLAPS', 'value': 'UP, NO LIGHT'},
      ]
    },
    {
      'title': 'DESCENT',
      'action': 'onB737Descent',
      'items': [
        {'item': 'PRESSURIZATION', 'value': 'LDG ALT ( )'},
        {'item': 'RECALL', 'value': 'CHECKED'},
        {'item': 'LANDING PERF CALC', 'value': 'DONE'},
        {'item': 'AUTOBRAKE', 'value': 'SET ( )'},
        {'item': 'LANDING DATA', 'value': 'VREF ( ) MINIMUMS ( )'},
        {'item': 'APPROACH BRIEFING', 'value': 'COMPLETED'},
      ]
    },
    {
      'title': 'APPROACH',
      'action': 'onB737Approach',
      'items': [
        {'item': 'ALTIMETERS', 'value': '( ) HPA/INHG'},
        {'item': 'NAV AIDS', 'value': 'SET'},
      ]
    },
    {
      'title': 'LANDING',
      'action': 'onB737Landing',
      'items': [
        {'item': 'ENG START SWITCHES', 'value': 'CONT'},
        {'item': 'SPEEDBRAKE', 'value': 'ARMED'},
        {'item': 'LANDING GEAR', 'value': 'DOWN. 3 GREEN'},
        {'item': 'FLAPS', 'value': '( ) GRN LIGHT'},
        {'item': 'LANDING RWY', 'value': '( ) CONFIRMED'},
      ]
    },
    {
      'title': 'PARKING',
      'action': 'onB737Parking',
      'items': [
        {'item': 'FUEL PUMPS', 'value': 'OFF'},
        {'item': 'PROBE HEAT', 'value': 'OFF'},
        {'item': 'HYDRAULIC PANEL', 'value': 'SET'},
        {'item': 'FLAPS', 'value': 'UP'},
        {'item': 'PARKING BRAKE', 'value': 'SET'},
        {'item': 'ENG START SWITCHES', 'value': 'CUTOFF'},
        {'item': 'WEATHER / TERRAIN RADAR', 'value': 'OFF'},
        {'item': 'TRANSPONDER', 'value': 'OFF'},
      ]
    },
  ];

  void _fireCallback(String actionName) {
    // Mapping string action names to widget callbacks
    switch (actionName) {
      // A320 Callbacks
      case 'onA320CockpitPrep':
        widget.onA320CockpitPrep?.call();
        break;
      case 'onA320BeforeStart':
        widget.onA320BeforeStart?.call();
        break;
      case 'onA320AfterStart':
        widget.onA320AfterStart?.call();
        break;
      case 'onA320Taxi':
        widget.onA320Taxi?.call();
        break;
      case 'onA320Lineup':
        widget.onA320Lineup?.call();
        break;
      case 'onA320DepartureChange':
        widget.onA320DepartureChange?.call();
        break;
      case 'onA320Approach':
        widget.onA320Approach?.call();
        break;
      case 'onA320Landing':
        widget.onA320Landing?.call();
        break;
      case 'onA320AfterLanding':
        widget.onA320AfterLanding?.call();
        break;
      case 'onA320Parking':
        widget.onA320Parking?.call();
        break;
      case 'onA320SecuringAircraft':
        widget.onA320SecuringAircraft?.call();
        break;

      // B737 Callbacks
      case 'onB737Preflight':
        widget.onB737Preflight?.call();
        break;
      case 'onB737BeforeStart':
        widget.onB737BeforeStart?.call();
        break;
      case 'onB737BeforeTaxi':
        widget.onB737BeforeTaxi?.call();
        break;
      case 'onB737BeforeTakeoff':
        widget.onB737BeforeTakeoff?.call();
        break;
      case 'onB737AfterTakeoff':
        widget.onB737AfterTakeoff?.call();
        break;
      case 'onB737Descent':
        widget.onB737Descent?.call();
        break;
      case 'onB737Approach':
        widget.onB737Approach?.call();
        break;
      case 'onB737Landing':
        widget.onB737Landing?.call();
        break;
      case 'onB737Parking':
        widget.onB737Parking?.call();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
    }

    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 800;

      return Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        color: const Color(0xFF0B111A), // Deep Navy Background
        child: Stack(
          children: [
            // المحتوى الرئيسي ملفوف بـ Positioned.fill لضمان أخذه كامل المساحة
            Positioned.fill(
              child: Column(
                children: [
                  // --- 1. Top Header Toggle ---
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom:
                              BorderSide(color: Color(0xFF1E293B), width: 1.5)),
                      color: Color(0xFF080D14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAircraftToggle(
                            'A320', _selectedAircraft == 'A320'),
                        const SizedBox(width: 16),
                        _buildAircraftToggle(
                            'B737', _selectedAircraft == 'B737'),
                      ],
                    ),
                  ),

                  // --- 2. Main Content (Masonry columns without gaps) ---
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: _buildChecklistLayout(
                          isMobile,
                          _selectedAircraft == 'A320'
                              ? _a320Checklists
                              : _b737Checklists,
                          constraints.maxWidth,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // شريط السحب السفلي (Home Indicator)
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
    });
  }

  Widget _buildAircraftToggle(String title, bool isActive) {
    return GestureDetector(
      onTap: () => _switchAircraft(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF3B82F6).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF2A3A52),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.airplanemode_active,
              color: isActive ? const Color(0xFF3B82F6) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Solution for the White Space issue: Real Masonry Layout via Columns ---
  Widget _buildChecklistLayout(
      bool isMobile, List<Map<String, dynamic>> checklists, double maxWidth) {
    if (isMobile) {
      // Mobile: Single column, everything stacked neatly
      return Column(
        children: checklists
            .map((data) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildChecklistCard(data),
                ))
            .toList(),
      );
    } else {
      // iPad: 3 equal-width columns. We distribute cards into these columns.
      // This prevents the "tallest card dictates row height" issue that Wrap causes.
      List<Widget> col1 = [];
      List<Widget> col2 = [];
      List<Widget> col3 = [];

      for (int i = 0; i < checklists.length; i++) {
        Widget card = Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildChecklistCard(checklists[i]),
        );

        // Distribute round-robin: 0->col1, 1->col2, 2->col3, 3->col1, etc.
        if (i % 3 == 0)
          col1.add(card);
        else if (i % 3 == 1)
          col2.add(card);
        else
          col3.add(card);
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: col1)),
          const SizedBox(width: 16),
          Expanded(child: Column(children: col2)),
          const SizedBox(width: 16),
          Expanded(child: Column(children: col3)),
        ],
      );
    }
  }

  Widget _buildChecklistCard(Map<String, dynamic> data) {
    List<dynamic> items = data['items'];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131B26), // Dark Glassmorphism card
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize:
            MainAxisSize.min, // Ensures card only takes height it needs
        children: [
          // Card Header with AI Button
          Container(
            padding:
                const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1A2436),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data['title'],
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                _buildAutoReadButton(data['action']),
              ],
            ),
          ),

          // Card Body (Items)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: items.asMap().entries.map((entry) {
                int idx = entry.key;
                var itemData = entry.value;
                bool isSubItem = itemData['item'].toString().startsWith(' -');

                return Padding(
                  padding: EdgeInsets.only(
                      bottom: idx == items.length - 1 ? 0 : 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          itemData['item'],
                          style: TextStyle(
                            color: isSubItem ? Colors.grey[400] : Colors.white,
                            fontSize: isSubItem ? 11 : 12,
                            fontWeight:
                                isSubItem ? FontWeight.normal : FontWeight.w600,
                          ),
                        ),
                      ),

                      // Dotted line filler for aesthetics
                      if (!isSubItem && itemData['value'].toString().isNotEmpty)
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              return Text(
                                '.' * (constraints.maxWidth / 3).floor(),
                                maxLines: 1,
                                style:
                                    const TextStyle(color: Color(0xFF2A3A52)),
                              );
                            }),
                          ),
                        ),

                      if (itemData['value'].toString().isNotEmpty)
                        Text(
                          itemData['value'],
                          style: const TextStyle(
                            color: Color(0xFF94A3B8), // Slate grey for values
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoReadButton(String actionName) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _fireCallback(actionName),
        borderRadius: BorderRadius.circular(20),
        splashColor: const Color(0xFF3B82F6).withOpacity(0.3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.5)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.record_voice_over, color: Color(0xFF3B82F6), size: 12),
              SizedBox(width: 4),
              Text(
                "AUTO-READ",
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- دالة إضافة شريط السحب السفلي المساعدة ---
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
}
