import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'subscription_managepage_model.dart';
export 'subscription_managepage_model.dart';

class SubscriptionManagepageWidget extends StatefulWidget {
  const SubscriptionManagepageWidget({super.key});

  static String routeName = 'subscriptionManagepage';
  static String routePath = '/subscriptionManagepage';

  @override
  State<SubscriptionManagepageWidget> createState() =>
      _SubscriptionManagepageWidgetState();
}

class _SubscriptionManagepageWidgetState
    extends State<SubscriptionManagepageWidget> {
  late SubscriptionManagepageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SubscriptionManagepageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
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
            'Subscription ',
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
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: custom_widgets.SubscriptionStatusCard(
                    width: double.infinity,
                    height: double.infinity,
                    status: getJsonField(
                      FFAppState().usersubscription,
                      r'''$.status''',
                    ).toString(),
                    simulatorType: getJsonField(
                      FFAppState().usersubscription,
                      r'''$.simulator_type''',
                    ).toString(),
                    expiryDate: getJsonField(
                      FFAppState().usersubscription,
                      r'''$.expiration_date''',
                    ).toString(),
                    priceText: getJsonField(
                      FFAppState().usersubscription,
                      r'''$.price_text''',
                    ).toString(),
                    planType: getJsonField(
                      FFAppState().usersubscription,
                      r'''$.plan_type''',
                    ).toString(),
                    onRestorePressed: () async {
                      _model.restoreRes3 =
                          await actions.restoreAllSubscriptions();
                      FFAppState().isProUserXplane = getJsonField(
                        _model.restoreRes3,
                        r'''$.is_xplane_active''',
                      );
                      FFAppState().isProUserMSFS = getJsonField(
                        _model.restoreRes3,
                        r'''$.is_msfs_active''',
                      );
                      FFAppState().usersubscription = _model.restoreRes3!;
                      safeSetState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            getJsonField(
                              _model.restoreRes3,
                              r'''$.message''',
                            ).toString(),
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context).primaryText,
                            ),
                          ),
                          duration: Duration(milliseconds: 4000),
                          backgroundColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                      );

                      safeSetState(() {});
                    },
                    onManageAppleSubscription: () async {
                      await launchURL(
                          'https://apps.apple.com/account/subscriptions');
                    },
                    onSupportPressed: () async {
                      await launchURL('https://discord.gg/3jJkuQeKaz');
                    },
                    onPrivacyPolicyPressed: () async {
                      context.pushNamed(PrivacyPolicyPageWidget.routeName);
                    },
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
