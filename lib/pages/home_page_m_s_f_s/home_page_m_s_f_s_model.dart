import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
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

  String? speed;

  String? altitude;

  double? heading;

  double? latitude;

  double? longitude;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetAirportInfo)] action in HomePageMSFS widget.
  ApiCallResponse? airportResulxxxxx;
  // Stores action output result for [Backend Call - API (GetSimBriefFlight)] action in HomePageMSFS widget.
  ApiCallResponse? simbreifResponse;
  // Stores action output result for [Backend Call - API (getMetarRaw)] action in HomePageMSFS widget.
  ApiCallResponse? metarResult;
  // Stores action output result for [Backend Call - API (getTafRaw)] action in HomePageMSFS widget.
  ApiCallResponse? tafResult;
  InstantTimer? instantTimer;
  // Stores action output result for [Custom Action - getFlightData] action in HomePageMSFS widget.
  dynamic flightDataMFSF;
  // State field(s) for TextFieldSpeedEntryLANDMARK widget.
  FocusNode? textFieldSpeedEntryLANDMARKFocusNode;
  TextEditingController? textFieldSpeedEntryLANDMARKTextController;
  String? Function(BuildContext, String?)?
      textFieldSpeedEntryLANDMARKTextControllerValidator;
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
  // State field(s) for RUNWAYLENGTHMSFS widget.
  FocusNode? runwaylengthmsfsFocusNode;
  TextEditingController? runwaylengthmsfsTextController;
  String? Function(BuildContext, String?)?
      runwaylengthmsfsTextControllerValidator;
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
  // State field(s) for RUNWAYLENGTHMSFSLANDING widget.
  FocusNode? runwaylengthmsfslandingFocusNode;
  TextEditingController? runwaylengthmsfslandingTextController;
  String? Function(BuildContext, String?)?
      runwaylengthmsfslandingTextControllerValidator;
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
  // State field(s) for TextFieldSpeedEntry widget.
  FocusNode? textFieldSpeedEntryFocusNode;
  TextEditingController? textFieldSpeedEntryTextController;
  String? Function(BuildContext, String?)?
      textFieldSpeedEntryTextControllerValidator;
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

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
    textFieldSpeedEntryLANDMARKFocusNode?.dispose();
    textFieldSpeedEntryLANDMARKTextController?.dispose();

    grossWeightFocusNode1?.dispose();
    grossWeightTextController1?.dispose();

    cgFocusNode?.dispose();
    cgTextController?.dispose();

    runwaylengthmsfsFocusNode?.dispose();
    runwaylengthmsfsTextController?.dispose();

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

    runwaylengthmsfslandingFocusNode?.dispose();
    runwaylengthmsfslandingTextController?.dispose();

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

    codeFocusNode?.dispose();
    codeTextController?.dispose();

    airportICAOFocusNode?.dispose();
    airportICAOTextController?.dispose();

    textFieldSpeedEntryFocusNode?.dispose();
    textFieldSpeedEntryTextController?.dispose();
  }
}
