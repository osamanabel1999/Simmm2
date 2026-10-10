import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 't_c_a_sxplane_model.dart';
export 't_c_a_sxplane_model.dart';

class TCASxplaneWidget extends StatefulWidget {
  const TCASxplaneWidget({super.key});

  static String routeName = 'TCASxplane';
  static String routePath = '/tCASxplane';

  @override
  State<TCASxplaneWidget> createState() => _TCASxplaneWidgetState();
}

class _TCASxplaneWidgetState extends State<TCASxplaneWidget> {
  late TCASxplaneModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TCASxplaneModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: custom_widgets.TcasControlPanel(
                  width: double.infinity,
                  height: double.infinity,
                  onGenerateAction: () async {
                    await actions.sendXPlaneCommand(
                      'xq7m4p9k/v3d8r1/g6n3x5',
                      FFAppState().ipPC,
                    );
                  },
                  onRemoveAllAction: () async {
                    await actions.sendXPlaneCommand(
                      'xq7m4p9k/v3d8r1/b2t9q6',
                      FFAppState().ipPC,
                    );
                  },
                  onPositionModeChanged: (mode) async {},
                  onAheadAction: (mode) async {
                    await actions.setXPlaneDataRef(
                      'xq7m4p9k/v3d8r1/p3n6x8',
                      0.0,
                      FFAppState().ipPC,
                    );
                  },
                  onBehindAction: (mode) async {
                    await actions.setXPlaneDataRef(
                      'xq7m4p9k/v3d8r1/p3n6x8',
                      1.0,
                      FFAppState().ipPC,
                    );
                  },
                  onLeftAction: (mode) async {
                    await actions.setXPlaneDataRef(
                      'xq7m4p9k/v3d8r1/p3n6x8',
                      2.0,
                      FFAppState().ipPC,
                    );
                  },
                  onRightAction: (mode) async {
                    await actions.setXPlaneDataRef(
                      'xq7m4p9k/v3d8r1/p3n6x8',
                      3.0,
                      FFAppState().ipPC,
                    );
                  },
                  onFrontLeftAction: (mode) async {
                    await actions.setXPlaneDataRef(
                      'xq7m4p9k/v3d8r1/p3n6x8',
                      4.0,
                      FFAppState().ipPC,
                    );
                  },
                  onFrontRightAction: (mode) async {
                    await actions.setXPlaneDataRef(
                      'xq7m4p9k/v3d8r1/p3n6x8',
                      5.0,
                      FFAppState().ipPC,
                    );
                  },
                  onRearLeftAction: (mode) async {
                    await actions.setXPlaneDataRef(
                      'xq7m4p9k/v3d8r1/p3n6x8',
                      6.0,
                      FFAppState().ipPC,
                    );
                  },
                  onRearRightAction: (mode) async {
                    await actions.setXPlaneDataRef(
                      'xq7m4p9k/v3d8r1/p3n6x8',
                      7.0,
                      FFAppState().ipPC,
                    );
                  },
                  onHeadingModeAction: (mode) async {
                    await actions.setXPlaneDataRef(
                      'xq7m4p9k/v3d8r1/p3n6x8',
                      8.0,
                      FFAppState().ipPC,
                    );
                  },
                  onDistanceChanged: (value) async {
                    await actions.setXPlaneDataRef(
                      'xq7m4p9k/v3d8r1/8f1c2',
                      value!,
                      FFAppState().ipPC,
                    );
                  },
                  onTrueAirspeedChanged: (value) async {
                    await actions.setXPlaneDataRef(
                      'xq7m4p9k/v3d8r1/2c6d4',
                      value!,
                      FFAppState().ipPC,
                    );
                  },
                  onRelativeAltitudeChanged: (value) async {
                    await actions.setXPlaneDataRef(
                      'xq7m4p9k/v3d8r1/19b7e',
                      value!,
                      FFAppState().ipPC,
                    );
                  },
                  onVerticalSpeedChanged: (value) async {
                    await actions.setXPlaneDataRef(
                      'xq7m4p9k/v3d8r1/7e0a9',
                      value!,
                      FFAppState().ipPC,
                    );
                  },
                  onCustomHeadingChanged: (value) async {
                    await actions.setXPlaneDataRef(
                      'xq7m4p9k/v3d8r1/4d2f8',
                      value!,
                      FFAppState().ipPC,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
