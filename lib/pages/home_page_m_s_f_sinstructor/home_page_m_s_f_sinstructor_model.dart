import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'home_page_m_s_f_sinstructor_widget.dart'
    show HomePageMSFSinstructorWidget;
import 'package:flutter/material.dart';

class HomePageMSFSinstructorModel
    extends FlutterFlowModel<HomePageMSFSinstructorWidget> {
  ///  Local state fields for this page.

  int currentStep = 1;

  double currentTime = 12.0;

  String generatedKey = 'mnmn';

  dynamic selectedRunway;

  String? speed;

  String? altitude;

  double? heading;

  double? latitude;

  double? longitude;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetSimBriefFlight)] action in HomePageMSFSinstructor widget.
  ApiCallResponse? simbreifResponse;
  // Stores action output result for [Custom Action - calculateA320SpeedsFull] action in ToPerformanceWidget widget.
  dynamic speedsResult1;
  // Stores action output result for [Custom Action - calculateA320Landing] action in LdaPerformanceWidget widget.
  dynamic calculateA320LandingNew;
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

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
