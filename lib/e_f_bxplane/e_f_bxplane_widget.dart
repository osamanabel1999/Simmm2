import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'e_f_bxplane_model.dart';
export 'e_f_bxplane_model.dart';

class EFBxplaneWidget extends StatefulWidget {
  const EFBxplaneWidget({super.key});

  static String routeName = 'EFBxplane';
  static String routePath = '/eFBxplane';

  @override
  State<EFBxplaneWidget> createState() => _EFBxplaneWidgetState();
}

class _EFBxplaneWidgetState extends State<EFBxplaneWidget> {
  late EFBxplaneModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EFBxplaneModel());
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
        backgroundColor: Color(0xFF0B111A),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: custom_widgets.EfbHomeScreenXplane(
            width: double.infinity,
            height: double.infinity,
            wallpaperUrl:
                'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/0B235E9F-F201-4F3D-9427-B0C9F254C522.png',
            iconAirportWx:
                'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/3A9717E3-7FE6-419C-BA85-42E69E2B60E6.png',
            iconWxCharts:
                'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/DFEF7F05-42D4-4615-A771-F20C2510FBE3.png',
            iconNotams:
                'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/46AB4E4F-D38B-435F-9730-D3C5EFCB39BD.png',
            iconScratchpad:
                'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/8B4CF9FB-FB3B-4E14-94F9-8433F4161703.png',
            iconSettings:
                'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/IMG_2364.jpeg',
            simbriefUserId: FFAppState().SimbreifID.toString(),
            iconFlightPlan:
                'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/54B58D01-89E8-4A8E-9D70-A9DC7118E7E0.png',
            iconBriefing:
                'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/E7FCF46D-F3B6-41D9-9075-B11C0FF5CD16.png',
            iconToPerf:
                'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/6CBCD1B9-AC8B-4476-8AB1-2893F61BB30E.png',
            iconLdgPerf:
                'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/8A80C062-64A7-4B5B-AC61-F3D4BC33F330.png',
            iconChecklist:
                'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/4DA62943-3380-46DA-A99D-E20508B74D1B.png',
            iconAiDispatcher:
                'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/1787F758-74ED-4ED2-84D9-49748D9E67CD.png',
            iconCabinPa:
                'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/21493C14-DEE6-4F06-9C72-36A1EFEB5B17.png',
            iconFlightCalc:
                'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/8A026F1D-464B-4002-8107-2225DEFB83A8.png',
            iconFlightBag:
                'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/6A2EF0ED-EAC1-4D7F-8242-985EC8995128.png',
            iconBrowser:
                'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/F49C9F7E-47B2-488F-BD97-149AD77997E5.png',
            iconSimControl:
                'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/A912B194-F96A-4386-BCB2-9C6BDF4E5320.png',
            onExitAction: () async {
              context.safePop();
            },
            onSettingsAction: () async {
              FFAppState().TabNumber = 13;
              safeSetState(() {});

              context.pushNamed(HomePageXPLANEWidget.routeName);
            },
            onFlightPlanAction: () async {
              FFAppState().EFBpageNumber = 3.0;
              safeSetState(() {});

              context.pushNamed(
                EFBappPagesxWidget.routeName,
                extra: <String, dynamic>{
                  '__transition_info__': TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                  ),
                },
              );
            },
            onBriefingAction: () async {
              FFAppState().EFBpageNumber = 2.0;
              safeSetState(() {});

              context.pushNamed(
                EFBappPagesxWidget.routeName,
                extra: <String, dynamic>{
                  '__transition_info__': TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.topToBottom,
                  ),
                },
              );
            },
            onToPerfAction: () async {
              FFAppState().EFBpageNumber = 4.0;
              safeSetState(() {});

              context.pushNamed(
                EFBappPagesxWidget.routeName,
                extra: <String, dynamic>{
                  '__transition_info__': TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.scale,
                    alignment: Alignment.bottomCenter,
                  ),
                },
              );
            },
            onLdgPerfAction: () async {
              FFAppState().EFBpageNumber = 5.0;
              safeSetState(() {});

              context.pushNamed(
                EFBappPagesxWidget.routeName,
                extra: <String, dynamic>{
                  '__transition_info__': TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.bottomToTop,
                  ),
                },
              );
            },
            onChecklistAction: () async {
              FFAppState().EFBpageNumber = 7.0;
              safeSetState(() {});

              context.pushNamed(
                EFBappPagesxWidget.routeName,
                extra: <String, dynamic>{
                  '__transition_info__': TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                    duration: Duration(milliseconds: 0),
                  ),
                },
              );
            },
            onAiDispatcherAction: () async {
              FFAppState().EFBpageNumber = 1.0;
              safeSetState(() {});

              context.pushNamed(
                EFBappPagesxWidget.routeName,
                extra: <String, dynamic>{
                  '__transition_info__': TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                  ),
                },
              );
            },
            onCabinPaAction: () async {
              FFAppState().EFBpageNumber = 9.0;
              safeSetState(() {});

              context.pushNamed(
                EFBappPagesxWidget.routeName,
                extra: <String, dynamic>{
                  '__transition_info__': TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                  ),
                },
              );
            },
            onFlightCalcAction: () async {
              FFAppState().EFBpageNumber = 6.0;
              safeSetState(() {});

              context.pushNamed(
                EFBappPagesxWidget.routeName,
                extra: <String, dynamic>{
                  '__transition_info__': TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                  ),
                },
              );
            },
            onFlightBagAction: () async {
              FFAppState().EFBpageNumber = 8.0;
              safeSetState(() {});

              context.pushNamed(
                EFBappPagesxWidget.routeName,
                extra: <String, dynamic>{
                  '__transition_info__': TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                  ),
                },
              );
            },
            onBrowserAction: () async {
              FFAppState().EFBpageNumber = 10.0;
              safeSetState(() {});

              context.pushNamed(
                EFBappPagesxWidget.routeName,
                extra: <String, dynamic>{
                  '__transition_info__': TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.bottomToTop,
                  ),
                },
              );
            },
            onSimControlAction: () async {
              context.pushNamed(
                EFBxplaneWidget.routeName,
                extra: <String, dynamic>{
                  '__transition_info__': TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.bottomToTop,
                  ),
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
