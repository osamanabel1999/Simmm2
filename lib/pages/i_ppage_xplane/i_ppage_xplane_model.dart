import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'i_ppage_xplane_widget.dart' show IPpageXplaneWidget;
import 'package:flutter/material.dart';

class IPpageXplaneModel extends FlutterFlowModel<IPpageXplaneWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - restoreAllSubscriptions] action in IPpageXplane widget.
  dynamic xplanePageRes;
  // State field(s) for TextFieldipPc widget.
  FocusNode? textFieldipPcFocusNode;
  TextEditingController? textFieldipPcTextController;
  String? Function(BuildContext, String?)? textFieldipPcTextControllerValidator;
  // State field(s) for TextFieldSimbreifID widget.
  FocusNode? textFieldSimbreifIDFocusNode;
  TextEditingController? textFieldSimbreifIDTextController;
  String? Function(BuildContext, String?)?
      textFieldSimbreifIDTextControllerValidator;
  // State field(s) for TextFieldIVAOid widget.
  FocusNode? textFieldIVAOidFocusNode;
  TextEditingController? textFieldIVAOidTextController;
  String? Function(BuildContext, String?)?
      textFieldIVAOidTextControllerValidator;
  // Stores action output result for [Custom Action - restoreAllSubscriptions] action in RichTextSpan widget.
  dynamic restoreRes2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldipPcFocusNode?.dispose();
    textFieldipPcTextController?.dispose();

    textFieldSimbreifIDFocusNode?.dispose();
    textFieldSimbreifIDTextController?.dispose();

    textFieldIVAOidFocusNode?.dispose();
    textFieldIVAOidTextController?.dispose();
  }
}
