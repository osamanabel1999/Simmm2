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

class SimulatorBottomMenu extends StatefulWidget {
  const SimulatorBottomMenu({
    super.key,
    this.width,
    this.height,
    this.positionAction,
    this.pauseAction,
    this.freezeAction,
    this.flightPlanAction,
    this.doorsAction,
    this.pushbackAction,
    this.mapAction,
    this.toPerfAction,
    this.ldgPerfAction,
    this.checklistAction,
    this.briefingAction,
    this.scratchAction,
    this.loadAction,
    this.failuresAction,
    this.settingsAction,
  });

  final double? width;
  final double? height;

  final Future Function()? positionAction;
  final Future Function()? pauseAction;
  final Future Function()? freezeAction;
  final Future Function()? flightPlanAction;
  final Future Function()? doorsAction;

  final Future Function()? pushbackAction;
  final Future Function()? mapAction;
  final Future Function()? toPerfAction;
  final Future Function()? ldgPerfAction;
  final Future Function()? checklistAction;

  final Future Function()? briefingAction;
  final Future Function()? scratchAction;
  final Future Function()? loadAction;
  final Future Function()? failuresAction;
  final Future Function()? settingsAction;

  @override
  State<SimulatorBottomMenu> createState() => _SimulatorBottomMenuState();
}

class _SimulatorBottomMenuState extends State<SimulatorBottomMenu> {
  int? _selectedIndex;
  int? _pressedIndex;

  static const Color _backgroundColor = Color(0xFF0B111A);

  static const Color _buttonColor = Color(0xFF101923);

  static const Color _buttonBorder = Color(0xFF26364D);

  static const Color _selectedColor = Color(0xFF123E72);

  static const Color _selectedBorder = Color(0xFF2C83EA);

  static const List<String> _labels = [
    'POSITION',
    'PAUSE',
    'FREEZE',
    'FLIGHTPLAN',
    'DOORS',
    'PUSHBACK',
    'MAP',
    'T/O PERF',
    'LDG PERF',
    'CHECKLIST',
    'BRIEFING',
    'EFB',
    'LOAD',
    'FAILURES',
    'SETTINGS',
  ];

  bool _isMomentaryButton(int index) {
    return index == 1 || index == 2;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: const Color(0xFF1E2C40),
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 14.0,
              spreadRadius: 1.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final double fontSize;
            if (width >= 900) {
              fontSize = 15.0;
            } else if (width >= 650) {
              fontSize = 14.0;
            } else if (width >= 400) {
              fontSize = 12.0;
            } else {
              fontSize = 10.0;
            }

            return Column(
              children: [
                Expanded(
                  child: _buildRow(
                    0,
                    fontSize,
                  ),
                ),
                const SizedBox(height: 7.0),
                Expanded(
                  child: _buildRow(
                    5,
                    fontSize,
                  ),
                ),
                const SizedBox(height: 7.0),
                Expanded(
                  child: _buildRow(
                    10,
                    fontSize,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRow(
    int startIndex,
    double fontSize,
  ) {
    return Row(
      children: List.generate(
        5,
        (column) {
          final index = startIndex + column;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: column == 0 ? 0 : 3,
                right: column == 4 ? 0 : 3,
              ),
              child: _buildButton(
                index,
                fontSize,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton(
    int index,
    double fontSize,
  ) {
    final bool momentary = _isMomentaryButton(index);

    final bool selected = !momentary && _selectedIndex == index;

    final bool pressed = _pressedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (!mounted) return;

        setState(() {
          _pressedIndex = index;
        });
      },
      onTapCancel: () {
        if (!mounted) return;

        setState(() {
          _pressedIndex = null;
        });
      },
      onTap: () async {
        if (!mounted) return;

        setState(() {
          _pressedIndex = index;
        });

        // PAUSE / FREEZE
        // They never become selected.
        if (momentary) {
          await _executeAction(index);

          if (!mounted) return;

          await Future.delayed(
            const Duration(milliseconds: 100),
          );

          if (!mounted) return;

          setState(() {
            _pressedIndex = null;
          });

          return;
        }

        // Normal button:
        // previous selected button loses its light.
        setState(() {
          _selectedIndex = index;
        });

        await _executeAction(index);

        if (!mounted) return;

        setState(() {
          _pressedIndex = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected
              ? _selectedColor
              : pressed
                  ? const Color(0xFF182A40)
                  : _buttonColor,
          borderRadius: BorderRadius.circular(7.0),
          border: Border.all(
            color: selected
                ? _selectedBorder
                : pressed
                    ? const Color(0xFF38587C)
                    : _buttonBorder,
            width: selected ? 1.2 : 1.0,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x55176FD8),
                    blurRadius: 10.0,
                    spreadRadius: 0.5,
                  ),
                  BoxShadow(
                    color: Color(0x33176FD8),
                    blurRadius: 18.0,
                    spreadRadius: -2.0,
                  ),
                ]
              : pressed
                  ? const [
                      BoxShadow(
                        color: Color(0x33176FD8),
                        blurRadius: 7.0,
                      ),
                    ]
                  : const [],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 120),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.15,
                    height: 1.0,
                    color: selected
                        ? const Color(0xFFEAF4FF)
                        : pressed
                            ? const Color(0xFFD5E5F8)
                            : const Color(0xFF9DACC2),
                  ),
                  child: Text(
                    _labels[index],
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 80),
              opacity: pressed ? 1.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7.0),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x221E90FF),
                      Color(0x001E90FF),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _executeAction(int index) async {
    switch (index) {
      case 0:
        await widget.positionAction?.call();
        break;

      case 1:
        await widget.pauseAction?.call();
        break;

      case 2:
        await widget.freezeAction?.call();
        break;

      case 3:
        await widget.flightPlanAction?.call();
        break;

      case 4:
        await widget.doorsAction?.call();
        break;

      case 5:
        await widget.pushbackAction?.call();
        break;

      case 6:
        await widget.mapAction?.call();
        break;

      case 7:
        await widget.toPerfAction?.call();
        break;

      case 8:
        await widget.ldgPerfAction?.call();
        break;

      case 9:
        await widget.checklistAction?.call();
        break;

      case 10:
        await widget.briefingAction?.call();
        break;

      case 11:
        await widget.scratchAction?.call();
        break;

      case 12:
        await widget.loadAction?.call();
        break;

      case 13:
        await widget.failuresAction?.call();
        break;

      case 14:
        await widget.settingsAction?.call();
        break;
    }
  }
}
