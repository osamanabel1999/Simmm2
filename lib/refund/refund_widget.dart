import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'refund_model.dart';
export 'refund_model.dart';

class RefundWidget extends StatefulWidget {
  const RefundWidget({super.key});

  static String routeName = 'Refund';
  static String routePath = '/refund';

  @override
  State<RefundWidget> createState() => _RefundWidgetState();
}

class _RefundWidgetState extends State<RefundWidget> {
  late RefundModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RefundModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Refund & Cancellation Policy',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            10.0, 0.0, 10.0, 0.0),
                        child: Text(
                          '\nRefund & Cancellation Policy\n\n1. Digital Products Nature\n\nAt Simulator Station, we provide digital software licenses that are accessible immediately upon purchase.\n\nDue to the nature of digital goods, once a \"Lifetime Access\" license is activated or the digital content is accessed, the service is considered \"consumed.\"\n\n2. Refund Eligibility\n\nWe strive for 100% customer satisfaction. Refund requests are handled on a case-by-case basis under the following conditions:\n\n• Technical Issues: If the software is proven to be non-functional on your device and our support team cannot resolve the issue within 7 business days.\n\n• Accidental Duplicate Purchase: If you accidentally purchased the same license twice, the duplicate charge will be fully refunded.\n\n• Non-Activation: If the license key has not been used or activated, you may request a refund within 14 days of the purchase date.\n\n3. Non-Refundable Cases\n\nRefunds will not be issued in the following scenarios:\n\n• Change of mind after the license has been activated.\n\n• Incompatibility with hardware or software versions clearly listed in our \"Requirements\" section.\n\n• Misuse of the software or violation of our Terms of Service.\n\n4. Cancellation Policy\n\nSince our service is a one-time purchase for lifetime access (not a recurring subscription), there is no ongoing \"cancellation\" required.\n\nOnce the payment is processed, the license is yours forever. No further charges will be applied to your account.\n\n5. How to Request a Refund\n\nTo initiate a refund request, please contact our support team at:semsimulator1@gmail.com\n\nPlease include your order number and a detailed description of the issue. Most requests are processed within 3-5 business days.\n',
                          textAlign: TextAlign.start,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
