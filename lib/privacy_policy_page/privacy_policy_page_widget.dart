import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'privacy_policy_page_model.dart';
export 'privacy_policy_page_model.dart';

class PrivacyPolicyPageWidget extends StatefulWidget {
  const PrivacyPolicyPageWidget({super.key});

  static String routeName = 'PrivacyPolicyPage';
  static String routePath = '/privacyPolicyPage';

  @override
  State<PrivacyPolicyPageWidget> createState() =>
      _PrivacyPolicyPageWidgetState();
}

class _PrivacyPolicyPageWidgetState extends State<PrivacyPolicyPageWidget> {
  late PrivacyPolicyPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PrivacyPolicyPageModel());
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
            'Privacy Policy',
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
                          '\nPrivacy Policy for Simulator Station\n\n\nWelcome to Simulator Station. Your privacy is critically important to us. This Privacy Policy explains how we handle your information when you use our mobile application.\n\n\n1. Introduction\n\nSimulator Station is a flight simulation tool designed for entertainment and educational purposes only. It is intended to be used as a virtual cockpit assistant for flight simulators (like X-Plane).\n\n\n2. Information We Collect and How We Use It\n\nWe take a \"Privacy by Design\" approach. Our app is designed to function with minimal data collection.\n\n• Local Network Data (IP Address): To connect the app to your Flight Simulator PC, the app requires your local IP address.\n\n• How we use it: This data is used only to establish a UDP/TCP connection between your mobile device and your PC.\n\n• Storage: This information is stored locally on your device and is never transmitted to our servers.\n\n• Microphone Access (Voice Checklist): The app requests microphone access to allow you to interact with the interactive cockpit checklists.\n\n• How we use it: Voice data is processed to convert speech to text using third-party AI models (e.g., Groq/Whisper).\n\n• Storage: We do not record, store, or share your audio files for any purpose other than real-time command processing.\n\n\n3. Third-Party Services\n\nTo provide AI-powered voice recognition, we may use third-party APIs. These services receive audio fragments solely for the purpose of transcription. They do not have access to your personal identity or other data on your device.\n\n\n4. Data Security\n\nSince the majority of your data (like your PC\'s IP) stays on your device, the risk of data breach is significantly minimized. We implement industry-standard security measures within the app to protect this local information.\n\n\n5. Important Legal Disclaimer\n\nSimulator Station is NOT a flight training tool for real-world aviation.\n\n• The application is for Virtual Flight Simulation Use Only.\n\n• It must never be used in a real aircraft or for real-world pilot certification/training.\n\n• The developer is not responsible for any misuse of the application outside of simulation environments.\n\n\n6. Changes to This Policy\n\nWe may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the \"Last Updated\" date.\n\n7. Contact Us\nIf you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at: semsimulator1@gmail.com',
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
