import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/revenue_cat_util.dart' as revenue_cat;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'subscription_managepage_xplane_lifetime_model.dart';
export 'subscription_managepage_xplane_lifetime_model.dart';

class SubscriptionManagepageXplaneLifetimeWidget extends StatefulWidget {
  const SubscriptionManagepageXplaneLifetimeWidget({super.key});

  static String routeName = 'subscriptionManagepageXplaneLifetime';
  static String routePath = '/subscriptionManagepageXplaneLifetime';

  @override
  State<SubscriptionManagepageXplaneLifetimeWidget> createState() =>
      _SubscriptionManagepageXplaneLifetimeWidgetState();
}

class _SubscriptionManagepageXplaneLifetimeWidgetState
    extends State<SubscriptionManagepageXplaneLifetimeWidget> {
  late SubscriptionManagepageXplaneLifetimeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model =
        createModel(context, () => SubscriptionManagepageXplaneLifetimeModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.currentPlanTypeMSFS = await actions.getPlanTypeMSFS(
        FFAppState().generateCodeMSFS,
      );
      FFAppState().currentPlanTypeMSFS = FFAppState().currentPlanTypeMSFS;
      safeSetState(() {});
    });
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
                    status: 'Active',
                    simulatorType: 'X-PLANE',
                    expiryDate: FFAppState().globalExpiryDate,
                    priceText: valueOrDefault<String>(
                      revenue_cat.offerings!.current!
                          .getPackage('xplane_lifetime')!
                          .storeProduct
                          .priceString,
                      '-',
                    ),
                    planType: valueOrDefault<String>(
                      revenue_cat.offerings!.current!
                          .getPackage('xplane_lifetime')!
                          .storeProduct
                          .title,
                      '-',
                    ),
                    onRestorePressed: () async {
                      _model.restoredCodeMSFS1 =
                          await actions.restoreLicenseMSFS();
                      if (_model.restoredCodeMSFS1 == 'License Expired.') {
                        await showDialog(
                          context: context,
                          builder: (alertDialogContext) {
                            return WebViewAware(
                              child: AlertDialog(
                                title: Text('Your MSFS License is Expired!'),
                                content: Text(
                                    'Your active MSFS license key has expired. Please renew your subscription.'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(alertDialogContext),
                                    child: Text('Ok'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else if (_model.restoredCodeMSFS1 ==
                          'No subscription found for this device.') {
                        await showDialog(
                          context: context,
                          builder: (alertDialogContext) {
                            return WebViewAware(
                              child: AlertDialog(
                                title: Text('No MSFS Subscription Found!'),
                                content: Text(
                                    'No MSFS subscription found for this device.'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(alertDialogContext),
                                    child: Text('Ok'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        await showDialog(
                          context: context,
                          builder: (alertDialogContext) {
                            return WebViewAware(
                              child: AlertDialog(
                                title: Text('MSFS Subscription Restored!'),
                                content: Text(
                                    'Your MSFS license key is:  ${valueOrDefault<String>(
                                  _model.restoredCodeMSFS1,
                                  '-',
                                )}'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(alertDialogContext),
                                    child: Text('Ok'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }

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
