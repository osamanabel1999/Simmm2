import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'aboutt_model.dart';
export 'aboutt_model.dart';

class AbouttWidget extends StatefulWidget {
  const AbouttWidget({super.key});

  static String routeName = 'Aboutt';
  static String routePath = '/aboutt';

  @override
  State<AbouttWidget> createState() => _AbouttWidgetState();
}

class _AbouttWidgetState extends State<AbouttWidget> {
  late AbouttModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AbouttModel());
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
            'About us',
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
                          '\nAbout Simulator Station\n\nAt Simulator Station, we aim to be the ultimate hub for flight simulation enthusiasts. We bridge the gap between desktop simulation and cockpit reality by providing professional-grade tools that enhance training, immersion, and operational accuracy.\nOur mission is to empower every \"Virtual Pilot\" with the technology used in real-world aviation.\n\n1. What We Do\n\nSimulator Station is a premier companion application specifically engineered for the Zibo 737 and X-Plane 11/12 platforms. We provide a sophisticated digital flight deck experience through:\n\n• Full Aircraft Mastery: Seamless, real-time interaction with complex aircraft systems.\n\n• Virtual Flight Partner: An AI-driven Co-Pilot for interactive briefings and smart checklists.\n\n• Operational Excellence: Advanced tools for performance calculations, weather management, and emergency drill simulation.\n\n2. Why Choose Simulator Station?\n\nBuilt by aviation experts for the simulation community, our platform focuses on technical precision, stability, and a premium user experience. Whether you are practicing for your real-world pilot license or flying for fun, Simulator Station is your gateway to a professional flight deck.\n\n3. Contact Us\n\nWe are always here to support your journey through the skies. For any inquiries or technical support, feel free to reach out to us:\n\n• Location: Sheikh Zayed, Giza, Egypt.\n• Phone: 0106 440 7360\n• Email: semsimulator1@gmail.com\n',
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
