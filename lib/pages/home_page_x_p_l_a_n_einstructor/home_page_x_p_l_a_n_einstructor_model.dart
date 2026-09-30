import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'home_page_x_p_l_a_n_einstructor_widget.dart'
    show HomePageXPLANEinstructorWidget;
import 'package:flutter/material.dart';

class HomePageXPLANEinstructorModel
    extends FlutterFlowModel<HomePageXPLANEinstructorWidget> {
  ///  Local state fields for this page.

  int currentStep = 1;

  double currentTime = 12.0;

  String generatedKey = 'mnmn';

  dynamic selectedRunway;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetAirportInfo)] action in HomePageXPLANEinstructor widget.
  ApiCallResponse? airportResulxxxxx;
  // Stores action output result for [Backend Call - API (GetSimBriefFlight)] action in HomePageXPLANEinstructor widget.
  ApiCallResponse? simbreifResponse;
  // Stores action output result for [Backend Call - API (getMetarRaw)] action in HomePageXPLANEinstructor widget.
  ApiCallResponse? metarResult;
  // Stores action output result for [Backend Call - API (getTafRaw)] action in HomePageXPLANEinstructor widget.
  ApiCallResponse? tafResult;
  InstantTimer? instantTimer;
  // Stores action output result for [Custom Action - listenToXPlane] action in HomePageXPLANEinstructor widget.
  double? headingoutput;
  // Stores action output result for [Custom Action - listenToXPlane] action in HomePageXPLANEinstructor widget.
  double? xoutput;
  // Stores action output result for [Custom Action - listenToXPlane] action in HomePageXPLANEinstructor widget.
  double? zoutput;
  // Stores action output result for [Custom Action - listenToXPlane] action in HomePageXPLANEinstructor widget.
  double? youtput;
  // Stores action output result for [Custom Action - listenToXPlane] action in HomePageXPLANEinstructor widget.
  double? lAToutput;
  // Stores action output result for [Custom Action - listenToXPlane] action in HomePageXPLANEinstructor widget.
  double? lONoutput;
  // Stores action output result for [Custom Action - listenToXPlane] action in HomePageXPLANEinstructor widget.
  double? sPDoutput;
  // Stores action output result for [Custom Action - listenToXPlane] action in HomePageXPLANEinstructor widget.
  double? aLToutput;
  InstantTimer? instantTimer2;
  // Stores action output result for [Custom Action - calculateXPlanePosition] action in HomePageXPLANEinstructor widget.
  dynamic autoResult;
  // Stores action output result for [Custom Action - calculateXPlanePosition] action in HomePageXPLANEinstructor widget.
  dynamic autoResultGate;
  // Stores action output result for [Custom Action - calculateXPlanePosition] action in HomePageXPLANEinstructor widget.
  dynamic autoResultGateChart;
  // Stores action output result for [Custom Action - calculateXPlanePosition] action in HomePageXPLANEinstructor widget.
  dynamic autoResultNVAIDS;
  // Stores action output result for [Custom Action - calculateXPlanePosition] action in HomePageXPLANEinstructor widget.
  dynamic autoResultTeleportonMap;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANEinstructor widget.
  dynamic sevenNMfinall;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANEinstructor widget.
  dynamic fiftenNMfinall;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANEinstructor widget.
  dynamic gateselectedXplane;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANEinstructor widget.
  dynamic tenNMfinall;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANEinstructor widget.
  dynamic cuisingFinal;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANEinstructor widget.
  dynamic zeroNMfinall;
  // Stores action output result for [Custom Action - calculateRightDownwindPosition] action in HomePageXPLANEinstructor widget.
  dynamic rightDownwind;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANEinstructor widget.
  dynamic teleportOnMAP;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANEinstructor widget.
  dynamic chartGateselectedXplane;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANEinstructor widget.
  dynamic nAVAIDSselectedXplane;
  // Stores action output result for [Custom Action - calculateBaseLegPosition] action in HomePageXPLANEinstructor widget.
  dynamic leftbase;
  // Stores action output result for [Custom Action - calculateLeftDownwindPosition] action in HomePageXPLANEinstructor widget.
  dynamic leftDownwind;
  // Stores action output result for [Custom Action - calculateRightBasePosition] action in HomePageXPLANEinstructor widget.
  dynamic rightBase;
  // Stores action output result for [Custom Action - calculateLeft45EntryPosition] action in HomePageXPLANEinstructor widget.
  dynamic left45;
  // Stores action output result for [Custom Action - calculateRight45EntryPosition] action in HomePageXPLANEinstructor widget.
  dynamic right45;
  // Stores action output result for [Custom Action - calculateVelocityVectorsXPlane] action in EFBRadarMap widget.
  dynamic vectorsResultTeleportonMAP;
  // State field(s) for TextFieldTOPhigh widget.
  FocusNode? textFieldTOPhighFocusNode;
  TextEditingController? textFieldTOPhighTextController;
  String? Function(BuildContext, String?)?
      textFieldTOPhighTextControllerValidator;
  // State field(s) for DropDownHIGH widget.
  String? dropDownHIGHValue1;
  FormFieldController<String>? dropDownHIGHValueController1;
  // State field(s) for TextFieldBOTTOMHIGH widget.
  FocusNode? textFieldBOTTOMHIGHFocusNode;
  TextEditingController? textFieldBOTTOMHIGHTextController;
  String? Function(BuildContext, String?)?
      textFieldBOTTOMHIGHTextControllerValidator;
  // State field(s) for DropDownHIGH widget.
  String? dropDownHIGHValue2;
  FormFieldController<String>? dropDownHIGHValueController2;
  // State field(s) for TextFieldTopMID widget.
  FocusNode? textFieldTopMIDFocusNode;
  TextEditingController? textFieldTopMIDTextController;
  String? Function(BuildContext, String?)?
      textFieldTopMIDTextControllerValidator;
  // State field(s) for DropDownMID widget.
  String? dropDownMIDValue1;
  FormFieldController<String>? dropDownMIDValueController1;
  // State field(s) for TextFieldBottomMID widget.
  FocusNode? textFieldBottomMIDFocusNode;
  TextEditingController? textFieldBottomMIDTextController;
  String? Function(BuildContext, String?)?
      textFieldBottomMIDTextControllerValidator;
  // State field(s) for DropDownMID widget.
  String? dropDownMIDValue2;
  FormFieldController<String>? dropDownMIDValueController2;
  // State field(s) for TextFieldTOPlow widget.
  FocusNode? textFieldTOPlowFocusNode;
  TextEditingController? textFieldTOPlowTextController;
  String? Function(BuildContext, String?)?
      textFieldTOPlowTextControllerValidator;
  // State field(s) for DropDownLOW widget.
  String? dropDownLOWValue1;
  FormFieldController<String>? dropDownLOWValueController1;
  // State field(s) for TextFieldBottomLOW widget.
  FocusNode? textFieldBottomLOWFocusNode;
  TextEditingController? textFieldBottomLOWTextController;
  String? Function(BuildContext, String?)?
      textFieldBottomLOWTextControllerValidator;
  // State field(s) for DropDownLOW widget.
  String? dropDownLOWValue2;
  FormFieldController<String>? dropDownLOWValueController2;
  // State field(s) for SliderVisibility widget.
  double? sliderVisibilityValue;
  // State field(s) for SliderQNH widget.
  double? sliderQNHValue;
  // State field(s) for SliderTemperature widget.
  double? sliderTemperatureValue;
  // State field(s) for SliderWindDir widget.
  double? sliderWindDirValue;
  // State field(s) for airportICAO widget.
  FocusNode? airportICAOFocusNode;
  TextEditingController? airportICAOTextController;
  String? Function(BuildContext, String?)? airportICAOTextControllerValidator;
  // Stores action output result for [Backend Call - API (GetAirportInfo)] action in Button widget.
  ApiCallResponse? airportResultApi;
  // State field(s) for Slidertime widget.
  double? slidertimeValue;
  // State field(s) for Sliderspeed widget.
  double? sliderspeedValue;
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
    textFieldTOPhighFocusNode?.dispose();
    textFieldTOPhighTextController?.dispose();

    textFieldBOTTOMHIGHFocusNode?.dispose();
    textFieldBOTTOMHIGHTextController?.dispose();

    textFieldTopMIDFocusNode?.dispose();
    textFieldTopMIDTextController?.dispose();

    textFieldBottomMIDFocusNode?.dispose();
    textFieldBottomMIDTextController?.dispose();

    textFieldTOPlowFocusNode?.dispose();
    textFieldTOPlowTextController?.dispose();

    textFieldBottomLOWFocusNode?.dispose();
    textFieldBottomLOWTextController?.dispose();

    airportICAOFocusNode?.dispose();
    airportICAOTextController?.dispose();
  }
}
