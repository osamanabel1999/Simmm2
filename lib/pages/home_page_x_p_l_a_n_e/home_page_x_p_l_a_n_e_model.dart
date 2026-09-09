import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
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

  // Stores action output result for [Backend Call - API (GetAirportInfo)] action in HomePageXPLANE widget.
  ApiCallResponse? airportResulxxxxx;
  // Stores action output result for [Backend Call - API (GetSimBriefFlight)] action in HomePageXPLANE widget.
  ApiCallResponse? simbreifResponse;
  // Stores action output result for [Backend Call - API (getMetarRaw)] action in HomePageXPLANE widget.
  ApiCallResponse? metarResult;
  // Stores action output result for [Backend Call - API (getTafRaw)] action in HomePageXPLANE widget.
  ApiCallResponse? tafResult;
  InstantTimer? instantTimer;
  // Stores action output result for [Custom Action - listenToXPlane] action in HomePageXPLANE widget.
  double? headingoutput;
  // Stores action output result for [Custom Action - listenToXPlane] action in HomePageXPLANE widget.
  double? xoutput;
  // Stores action output result for [Custom Action - listenToXPlane] action in HomePageXPLANE widget.
  double? zoutput;
  // Stores action output result for [Custom Action - listenToXPlane] action in HomePageXPLANE widget.
  double? lAToutput;
  // Stores action output result for [Custom Action - listenToXPlane] action in HomePageXPLANE widget.
  double? lONoutput;
  // Stores action output result for [Custom Action - listenToXPlane] action in HomePageXPLANE widget.
  double? sPDoutput;
  // Stores action output result for [Custom Action - listenToXPlane] action in HomePageXPLANE widget.
  double? aLToutput;
  // Stores action output result for [Custom Action - calculateXPlanePosition] action in HomePageXPLANE widget.
  dynamic autoResult;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANE widget.
  dynamic threeNMfinall;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANE widget.
  dynamic tenNMfinall;
  // Stores action output result for [Custom Action - moveAircraftBackward] action in HomePageXPLANE widget.
  dynamic zeroNMfinall;
  // Stores action output result for [Custom Action - calculateBaseLegPosition] action in HomePageXPLANE widget.
  dynamic leftbase;
  // Stores action output result for [Custom Action - calculateRightBasePosition] action in HomePageXPLANE widget.
  dynamic rightBase;
  // Stores action output result for [Custom Action - calculateLeftDownwindPosition] action in HomePageXPLANE widget.
  dynamic leftDownwind;
  // Stores action output result for [Custom Action - calculateLeft45EntryPosition] action in HomePageXPLANE widget.
  dynamic left45;
  // Stores action output result for [Custom Action - calculateRight45EntryPosition] action in HomePageXPLANE widget.
  dynamic right45;
  // Stores action output result for [Custom Action - calculateRightDownwindPosition] action in HomePageXPLANE widget.
  dynamic rightDownwind;
  // State field(s) for AircraftType widget.
  String? aircraftTypeValue1;
  FormFieldController<String>? aircraftTypeValueController1;
  // State field(s) for GrossWeight widget.
  FocusNode? grossWeightFocusNode1;
  TextEditingController? grossWeightTextController1;
  String? Function(BuildContext, String?)? grossWeightTextController1Validator;
  // State field(s) for CG widget.
  FocusNode? cgFocusNode;
  TextEditingController? cgTextController;
  String? Function(BuildContext, String?)? cgTextControllerValidator;
  // State field(s) for flapsIndex widget.
  String? flapsIndexValue1;
  FormFieldController<String>? flapsIndexValueController1;
  // State field(s) for antiIceIndex widget.
  String? antiIceIndexValue1;
  FormFieldController<String>? antiIceIndexValueController1;
  // State field(s) for isPacksOn widget.
  String? isPacksOnValue;
  FormFieldController<String>? isPacksOnValueController;
  // State field(s) for RUNWAYLENGTHXPLANETAKEOFF widget.
  FocusNode? runwaylengthxplanetakeoffFocusNode;
  TextEditingController? runwaylengthxplanetakeoffTextController;
  String? Function(BuildContext, String?)?
      runwaylengthxplanetakeoffTextControllerValidator;
  // State field(s) for RunwayHeading widget.
  FocusNode? runwayHeadingFocusNode1;
  TextEditingController? runwayHeadingTextController1;
  String? Function(BuildContext, String?)?
      runwayHeadingTextController1Validator;
  // State field(s) for Slope widget.
  FocusNode? slopeFocusNode1;
  TextEditingController? slopeTextController1;
  String? Function(BuildContext, String?)? slopeTextController1Validator;
  // State field(s) for isWet widget.
  String? isWetValue1;
  FormFieldController<String>? isWetValueController1;
  // State field(s) for AirportElevation widget.
  FocusNode? airportElevationFocusNode1;
  TextEditingController? airportElevationTextController1;
  String? Function(BuildContext, String?)?
      airportElevationTextController1Validator;
  // State field(s) for QNH widget.
  FocusNode? qnhFocusNode1;
  TextEditingController? qnhTextController1;
  String? Function(BuildContext, String?)? qnhTextController1Validator;
  // State field(s) for Temperature widget.
  FocusNode? temperatureFocusNode1;
  TextEditingController? temperatureTextController1;
  String? Function(BuildContext, String?)? temperatureTextController1Validator;
  // State field(s) for winddirection widget.
  FocusNode? winddirectionFocusNode1;
  TextEditingController? winddirectionTextController1;
  String? Function(BuildContext, String?)?
      winddirectionTextController1Validator;
  // State field(s) for WindSpeed widget.
  FocusNode? windSpeedFocusNode1;
  TextEditingController? windSpeedTextController1;
  String? Function(BuildContext, String?)? windSpeedTextController1Validator;
  // Stores action output result for [Custom Action - calculateA320SpeedsFull] action in Button widget.
  dynamic speedsResult;
  // State field(s) for AircraftType widget.
  String? aircraftTypeValue2;
  FormFieldController<String>? aircraftTypeValueController2;
  // State field(s) for GrossWeight widget.
  FocusNode? grossWeightFocusNode2;
  TextEditingController? grossWeightTextController2;
  String? Function(BuildContext, String?)? grossWeightTextController2Validator;
  // State field(s) for AirportElevation widget.
  FocusNode? airportElevationFocusNode2;
  TextEditingController? airportElevationTextController2;
  String? Function(BuildContext, String?)?
      airportElevationTextController2Validator;
  // State field(s) for flapsIndex widget.
  String? flapsIndexValue2;
  FormFieldController<String>? flapsIndexValueController2;
  // State field(s) for antiIceIndex widget.
  String? antiIceIndexValue2;
  FormFieldController<String>? antiIceIndexValueController2;
  // State field(s) for Reverse widget.
  String? reverseValue;
  FormFieldController<String>? reverseValueController;
  // State field(s) for RUNWAYLENGTHXPLANELDA widget.
  FocusNode? runwaylengthxplaneldaFocusNode;
  TextEditingController? runwaylengthxplaneldaTextController;
  String? Function(BuildContext, String?)?
      runwaylengthxplaneldaTextControllerValidator;
  // State field(s) for RunwayHeading widget.
  FocusNode? runwayHeadingFocusNode2;
  TextEditingController? runwayHeadingTextController2;
  String? Function(BuildContext, String?)?
      runwayHeadingTextController2Validator;
  // State field(s) for Slope widget.
  FocusNode? slopeFocusNode2;
  TextEditingController? slopeTextController2;
  String? Function(BuildContext, String?)? slopeTextController2Validator;
  // State field(s) for isWet widget.
  String? isWetValue2;
  FormFieldController<String>? isWetValueController2;
  // State field(s) for Autobrake widget.
  String? autobrakeValue;
  FormFieldController<String>? autobrakeValueController;
  // State field(s) for QNH widget.
  FocusNode? qnhFocusNode2;
  TextEditingController? qnhTextController2;
  String? Function(BuildContext, String?)? qnhTextController2Validator;
  // State field(s) for Temperature widget.
  FocusNode? temperatureFocusNode2;
  TextEditingController? temperatureTextController2;
  String? Function(BuildContext, String?)? temperatureTextController2Validator;
  // State field(s) for winddirection widget.
  FocusNode? winddirectionFocusNode2;
  TextEditingController? winddirectionTextController2;
  String? Function(BuildContext, String?)?
      winddirectionTextController2Validator;
  // State field(s) for WindSpeed widget.
  FocusNode? windSpeedFocusNode2;
  TextEditingController? windSpeedTextController2;
  String? Function(BuildContext, String?)? windSpeedTextController2Validator;
  // Stores action output result for [Custom Action - calculateA320Landing] action in Button widget.
  dynamic calculateA320Landing;
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
  // State field(s) for CODE widget.
  FocusNode? codeFocusNode;
  TextEditingController? codeTextController;
  String? Function(BuildContext, String?)? codeTextControllerValidator;
  // Stores action output result for [Backend Call - API (CheckLicense)] action in Button widget.
  ApiCallResponse? checkResult;
  // Stores action output result for [Backend Call - API (AddLicense)] action in Button widget.
  ApiCallResponse? apiResult631;
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
  // Stores action output result for [Backend Call - API (GetSimBriefFlight)] action in ColumnFlightPlan widget.
  ApiCallResponse? simbreifResponse1;
  // State field(s) for Sliderpayloadn widget.
  double? sliderpayloadnValue;
  // State field(s) for SliderTotalFuelWeight widget.
  double? sliderTotalFuelWeightValue;
  // State field(s) for SliderLInner widget.
  double? sliderLInnerValue;
  // State field(s) for SliderLOuter widget.
  double? sliderLOuterValue;
  // State field(s) for SliderCGn widget.
  double? sliderCGnValue;
  // State field(s) for SliderCenterFuelTank widget.
  double? sliderCenterFuelTankValue;
  // State field(s) for SliderRInner widget.
  double? sliderRInnerValue;
  // State field(s) for SliderROuter widget.
  double? sliderROuterValue;
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
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered9 = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
    grossWeightFocusNode1?.dispose();
    grossWeightTextController1?.dispose();

    cgFocusNode?.dispose();
    cgTextController?.dispose();

    runwaylengthxplanetakeoffFocusNode?.dispose();
    runwaylengthxplanetakeoffTextController?.dispose();

    runwayHeadingFocusNode1?.dispose();
    runwayHeadingTextController1?.dispose();

    slopeFocusNode1?.dispose();
    slopeTextController1?.dispose();

    airportElevationFocusNode1?.dispose();
    airportElevationTextController1?.dispose();

    qnhFocusNode1?.dispose();
    qnhTextController1?.dispose();

    temperatureFocusNode1?.dispose();
    temperatureTextController1?.dispose();

    winddirectionFocusNode1?.dispose();
    winddirectionTextController1?.dispose();

    windSpeedFocusNode1?.dispose();
    windSpeedTextController1?.dispose();

    grossWeightFocusNode2?.dispose();
    grossWeightTextController2?.dispose();

    airportElevationFocusNode2?.dispose();
    airportElevationTextController2?.dispose();

    runwaylengthxplaneldaFocusNode?.dispose();
    runwaylengthxplaneldaTextController?.dispose();

    runwayHeadingFocusNode2?.dispose();
    runwayHeadingTextController2?.dispose();

    slopeFocusNode2?.dispose();
    slopeTextController2?.dispose();

    qnhFocusNode2?.dispose();
    qnhTextController2?.dispose();

    temperatureFocusNode2?.dispose();
    temperatureTextController2?.dispose();

    winddirectionFocusNode2?.dispose();
    winddirectionTextController2?.dispose();

    windSpeedFocusNode2?.dispose();
    windSpeedTextController2?.dispose();

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

    codeFocusNode?.dispose();
    codeTextController?.dispose();

    airportICAOFocusNode?.dispose();
    airportICAOTextController?.dispose();
  }
}
