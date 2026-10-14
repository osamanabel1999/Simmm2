import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'home_page_x_p_l_a_n_e_widget.dart' show HomePageXPLANEWidget;
import 'package:flutter/material.dart';

class HomePageXPLANEModel extends FlutterFlowModel<HomePageXPLANEWidget> {
  ///  Local state fields for this page.

  int currentStep = 1;

  double currentTime = 12.0;

  String generatedKey = 'mnmn';

  dynamic selectedRunway;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetSimBriefFlight)] action in HomePageXPLANE widget.
  ApiCallResponse? simbreifResponse;
  InstantTimer? instantTimer;
  InstantTimer? instantTimer2;
  // Stores action output result for [Custom Action - calculateXPlanePosition] action in HomePageXPLANE widget.
  dynamic autoResult;
  // Stores action output result for [Custom Action - calculateXPlanePosition] action in HomePageXPLANE widget.
  dynamic autoResultGate;
  // Stores action output result for [Custom Action - calculateXPlanePosition] action in HomePageXPLANE widget.
  dynamic autoResultGateChart;
  // Stores action output result for [Custom Action - calculateXPlanePosition] action in HomePageXPLANE widget.
  dynamic autoResultNVAIDS;
  // Stores action output result for [Custom Action - calculateXPlanePosition] action in HomePageXPLANE widget.
  dynamic autoResultTeleportonMap;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANE widget.
  dynamic sevenNMfinall;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANE widget.
  dynamic fiftenNMfinall;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANE widget.
  dynamic gateselectedXplane;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANE widget.
  dynamic tenNMfinall;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANE widget.
  dynamic cuisingFinal;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANE widget.
  dynamic zeroNMfinall;
  // Stores action output result for [Custom Action - calculateRightDownwindPosition] action in HomePageXPLANE widget.
  dynamic rightDownwind;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANE widget.
  dynamic teleportOnMAP;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANE widget.
  dynamic chartGateselectedXplane;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANE widget.
  dynamic nAVAIDSselectedXplane;
  // Stores action output result for [Custom Action - calculateBaseLegPosition] action in HomePageXPLANE widget.
  dynamic leftbase;
  // Stores action output result for [Custom Action - calculateLeftDownwindPosition] action in HomePageXPLANE widget.
  dynamic leftDownwind;
  // Stores action output result for [Custom Action - calculateRightBasePosition] action in HomePageXPLANE widget.
  dynamic rightBase;
  // Stores action output result for [Custom Action - calculateLeft45EntryPosition] action in HomePageXPLANE widget.
  dynamic left45;
  // Stores action output result for [Custom Action - calculateRight45EntryPosition] action in HomePageXPLANE widget.
  dynamic right45;
  // Stores action output result for [Custom Action - calculateVelocityVectorsXPlane] action in EFBRadarMap widget.
  dynamic vectorsResultTeleportonMAP;
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
  // Stores action output result for [Custom Action - calculateVelocityVectorsXPlane] action in Xplin widget.
  dynamic vectorsResult3;
  // Stores action output result for [Custom Action - calculateVelocityVectorsXPlane] action in Xplin widget.
  dynamic vectorsResult2;
  // Stores action output result for [Custom Action - calculateExactLocalY] action in Xplin widget.
  double? finalYtakeoff;
  // Stores action output result for [Custom Action - calculateVelocityVectorsXPlane] action in Xplin widget.
  dynamic vectorsResult5;
  // Stores action output result for [Custom Action - calculateVelocityVectorsXPlane] action in Xplin widget.
  dynamic vectorsResult4;
  // Stores action output result for [Custom Action - calculateVelocityVectorsXPlane] action in Xplin widget.
  dynamic vectorsResult7;
  // Stores action output result for [Backend Call - API (GetElevation)] action in Xplin widget.
  ApiCallResponse? elevationDataXplaneRWY1;
  // Stores action output result for [Custom Action - calculateVelocityVectorsXPlane] action in Xplin widget.
  dynamic vectorsResult8;
  // Stores action output result for [Custom Action - calculateVelocityVectorsXPlane] action in Xplin widget.
  dynamic vectorsResult6;
  // Stores action output result for [Custom Action - calculateVelocityVectorsXPlane] action in Xplin widget.
  dynamic vectorsResult1;
  // Stores action output result for [Backend Call - API (GetElevation)] action in Xplin widget.
  ApiCallResponse? elevationDataXplaneGATE1;
  // Stores action output result for [Custom Action - calculateExactLocalY] action in Xplin widget.
  double? finalYgate;
  // Stores action output result for [Backend Call - API (GetElevation)] action in Xplin widget.
  ApiCallResponse? elevationDataXplaneNAVAIDS;
  // Stores action output result for [Backend Call - API (GetElevation)] action in Xplin widget.
  ApiCallResponse? elevationDataXplaneChartGATE;
  // Stores action output result for [Custom Action - calculateExactLocalY] action in Xplin widget.
  double? finalYgateChart;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
    instantTimer2?.cancel();
  }
}
