import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'e_f_bapp_pages_x_plane_model.dart';
export 'e_f_bapp_pages_x_plane_model.dart';

class EFBappPagesXPlaneWidget extends StatefulWidget {
  const EFBappPagesXPlaneWidget({super.key});

  static String routeName = 'EFBappPagesXPlane';
  static String routePath = '/eFBappPagesXPlane';

  @override
  State<EFBappPagesXPlaneWidget> createState() =>
      _EFBappPagesXPlaneWidgetState();
}

class _EFBappPagesXPlaneWidgetState extends State<EFBappPagesXPlaneWidget> {
  late EFBappPagesXPlaneModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EFBappPagesXPlaneModel());
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
            if (FFAppState().EFBpageNumber == 10.0)
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: custom_widgets.EfbBrowserScreen(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            if (FFAppState().EFBpageNumber == 8.0)
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: custom_widgets.EfbLibraryScreen(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            if (FFAppState().EFBpageNumber == 6.0)
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: custom_widgets.EfbCalculatorsScreen(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            if (FFAppState().EFBpageNumber == 9.0)
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: custom_widgets.CabinPaSystemScreen(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            if (FFAppState().EFBpageNumber == 2.0)
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: custom_widgets.EfbBriefingScreen(
                    width: double.infinity,
                    height: double.infinity,
                    pilotId: FFAppState().SimbreifID.toString(),
                  ),
                ),
              ),
            if (FFAppState().EFBpageNumber == 1.0)
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: custom_widgets.AiDispatcherScreen(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            if (FFAppState().EFBpageNumber == 4.0)
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: custom_widgets.ToPerformanceWidget(
                    width: double.infinity,
                    height: double.infinity,
                    pilotId: FFAppState().SimbreifID.toString(),
                    onCalculatePressed: (acType,
                        gw,
                        cg,
                        config,
                        aice,
                        aircond,
                        rwyLen,
                        rwyHdg,
                        slope,
                        rwyCond,
                        aptElev,
                        qnh,
                        temp,
                        windDir,
                        windSpd) async {},
                  ),
                ),
              ),
            if (FFAppState().EFBpageNumber == 5.0)
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: custom_widgets.LdaPerformanceWidget(
                    width: double.infinity,
                    height: double.infinity,
                    pilotId: FFAppState().SimbreifID.toString(),
                    onCalculatePressed: (acType,
                        gw,
                        aptElev,
                        config,
                        aice,
                        revInop,
                        rwyLen,
                        rwyHdg,
                        slope,
                        rwyCond,
                        autobrake,
                        qnh,
                        temp,
                        windDir,
                        windSpd) async {},
                  ),
                ),
              ),
            if (FFAppState().EFBpageNumber == 7.0)
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: custom_widgets.ChecklistEFBmsfs(
                    width: double.infinity,
                    height: double.infinity,
                    onA320CockpitPrep: () async {
                      await actions.runCockpitPreparation();
                    },
                    onA320BeforeStart: () async {
                      await actions.runBeforeStartChecklist();
                    },
                    onA320AfterStart: () async {
                      await actions.runAfterStartChecklist();
                    },
                    onA320Taxi: () async {
                      await actions.runTaxiChecklist();
                    },
                    onA320Lineup: () async {
                      await actions.runLineUpChecklist();
                    },
                    onA320DepartureChange: () async {
                      await actions.runDepartureChecklist();
                    },
                    onA320Approach: () async {
                      await actions.runApproachChecklist();
                    },
                    onA320Landing: () async {
                      await actions.runLandingChecklist();
                    },
                    onA320AfterLanding: () async {
                      await actions.runAfterLandingChecklist();
                    },
                    onA320Parking: () async {
                      await actions.runParkingChecklist();
                    },
                    onA320SecuringAircraft: () async {
                      await actions.runSecuringChecklist();
                    },
                    onB737Preflight: () async {
                      await action_blocks.test(context);
                    },
                    onB737BeforeStart: () async {
                      await actions.runB737BeforeStartChecklist();
                    },
                    onB737BeforeTaxi: () async {
                      await actions.runB737BeforeTaxiChecklist();
                    },
                    onB737BeforeTakeoff: () async {
                      await actions.runB737BeforeTakeoffChecklist();
                    },
                    onB737AfterTakeoff: () async {
                      await actions.runB737AfterTakeoffChecklist();
                    },
                    onB737Descent: () async {
                      await actions.runB737DescentChecklist();
                    },
                    onB737Approach: () async {
                      await actions.runB737ApproachChecklist();
                    },
                    onB737Landing: () async {
                      await actions.runB737LandingChecklist();
                    },
                    onB737Parking: () async {
                      await actions.runB737ParkingChecklist();
                    },
                  ),
                ),
              ),
            if (FFAppState().EFBpageNumber == 3.0)
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: custom_widgets.EfbFlightPlanScreen(
                    width: double.infinity,
                    height: double.infinity,
                    pilotId: FFAppState().SimbreifID.toString(),
                    currentLat: FFAppState().currentLAT,
                    currentLon: FFAppState().currentLON,
                    pdfLink: FFAppState().PDFlinkSimbreif,
                    onDepartureAtisPressed: () async {
                      await actions.professionalAtis(
                        'hiiiii',
                      );
                    },
                    onArrivalAtisPressed: () async {
                      await actions.professionalAtis(
                        'ATIS',
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
