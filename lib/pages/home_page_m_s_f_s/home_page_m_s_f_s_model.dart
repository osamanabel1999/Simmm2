import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'home_page_m_s_f_s_widget.dart' show HomePageMSFSWidget;
import 'package:flutter/material.dart';

class HomePageMSFSModel extends FlutterFlowModel<HomePageMSFSWidget> {
  ///  Local state fields for this page.

  int currentStep = 1;

  double currentTime = 12.0;

  String generatedKey = 'mnmn';

  dynamic selectedRunway;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetSimBriefFlight)] action in HomePageMSFS widget.
  ApiCallResponse? simbreifResponse;
  InstantTimer? instantTimer;
  // Stores action output result for [Custom Action - getFlightData] action in HomePageMSFS widget.
  dynamic flightDataMFSF;
  // State field(s) for TextFieldSpeedEntryLANDMARK widget.
  FocusNode? textFieldSpeedEntryLANDMARKFocusNode;
  TextEditingController? textFieldSpeedEntryLANDMARKTextController;
  String? Function(BuildContext, String?)?
      textFieldSpeedEntryLANDMARKTextControllerValidator;
  // Stores action output result for [Custom Action - calculateA320SpeedsFull] action in ToPerformanceWidget widget.
  dynamic speedsResult1;
  // Stores action output result for [Custom Action - calculateA320Landing] action in LdaPerformanceWidget widget.
  dynamic calculateA320LandingNew;
  // Stores action output result for [Backend Call - API (GetSimBriefFlight)] action in ColumnFlightPlanxxx widget.
  ApiCallResponse? simbreifResponse1;
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered1 = false;
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered2 = false;
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered3 = false;
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered4 = false;
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered5 = false;
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered6 = false;
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered7 = false;
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered8 = false;
  // Stores action output result for [Backend Call - API (GetElevation)] action in EliteAviationEFB widget.
  ApiCallResponse? elevationDataMSFSrwy;
  // Stores action output result for [Backend Call - API (GetElevation)] action in EliteAviationEFB widget.
  ApiCallResponse? elevationDataMSFSgate;
  // Stores action output result for [Backend Call - API (GetElevation)] action in EliteAviationEFB widget.
  ApiCallResponse? elevationDataMSFSchartGate;
  // Stores action output result for [Backend Call - API (GetElevation)] action in EliteAviationEFB widget.
  ApiCallResponse? elevationDataMSFSANAVAIDS;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
    textFieldSpeedEntryLANDMARKFocusNode?.dispose();
    textFieldSpeedEntryLANDMARKTextController?.dispose();
  }
}
