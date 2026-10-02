import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
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
  void dispose() {
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
  }
}
