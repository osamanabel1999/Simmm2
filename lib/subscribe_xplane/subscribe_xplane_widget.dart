import '/flutter_flow/flutter_flow_ad_banner.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/revenue_cat_util.dart' as revenue_cat;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'subscribe_xplane_model.dart';
export 'subscribe_xplane_model.dart';

class SubscribeXplaneWidget extends StatefulWidget {
  const SubscribeXplaneWidget({super.key});

  static String routeName = 'SubscribeXplane';
  static String routePath = '/subscribeXplane';

  @override
  State<SubscribeXplaneWidget> createState() => _SubscribeXplaneWidgetState();
}

class _SubscribeXplaneWidgetState extends State<SubscribeXplaneWidget> {
  late SubscribeXplaneModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SubscribeXplaneModel());
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: Color(0xFF14181B),
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
            'X-Plane Access Plans',
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
                  child: custom_widgets.Bfmccheckout(
                    width: double.infinity,
                    height: double.infinity,
                    monthlyPrice: revenue_cat.offerings!.current!
                        .getPackage('xplane_monthly')!
                        .storeProduct
                        .priceString,
                    yearlyPrice: revenue_cat.offerings!.current!
                        .getPackage('xplane_yearly')!
                        .storeProduct
                        .priceString,
                    lifetimePrice: revenue_cat.offerings!.current!
                        .getPackage('xplane_lifetime')!
                        .storeProduct
                        .priceString,
                    onBuyMonthly: () async {
                      _model.xplanemonthly =
                          await revenue_cat.purchasePackage('xplane_monthly');
                      if (_model.xplanemonthly == true) {
                        context.pushNamed(IPpageXplaneWidget.routeName);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Payment failed or was cancelled. Please try again.',
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                            duration: Duration(milliseconds: 4000),
                            backgroundColor:
                                FlutterFlowTheme.of(context).primaryBackground,
                          ),
                        );
                      }

                      safeSetState(() {});
                    },
                    onBuyYearly: () async {
                      _model.xplaneyearly =
                          await revenue_cat.purchasePackage('xplane_yearly');
                      if (_model.xplaneyearly == true) {
                        context.pushNamed(IPpageXplaneWidget.routeName);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Payment failed or was cancelled. Please try again.',
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                            duration: Duration(milliseconds: 4000),
                            backgroundColor:
                                FlutterFlowTheme.of(context).primaryBackground,
                          ),
                        );
                      }

                      safeSetState(() {});
                    },
                    onBuyLifetime: () async {
                      _model.xplaneLifetime =
                          await revenue_cat.purchasePackage('xplane_lifetime');
                      if (_model.xplaneLifetime == true) {
                        context.pushNamed(IPpageXplaneWidget.routeName);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Payment failed or was cancelled. Please try again.',
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                            duration: Duration(milliseconds: 4000),
                            backgroundColor:
                                FlutterFlowTheme.of(context).primaryBackground,
                          ),
                        );
                      }

                      safeSetState(() {});
                    },
                    onContactUs: () async {
                      await launchURL('https://discord.gg/3jJkuQeKaz');
                    },
                    onBuyBothSims: () async {
                      context.pushNamed(
                          SubscribePackageXplaneMSFSWidget.routeName);
                    },
                    onTermsOfUse: () async {
                      context.pushNamed(TermsOFuseWidget.routeName);
                    },
                    onPrivacyPolicy: () async {
                      context.pushNamed(PrivacyPolicyPageWidget.routeName);
                    },
                  ),
                ),
              ),
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
                tabletLandscape: false,
                desktop: false,
              ))
                FlutterFlowAdBanner(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  height: 50.0,
                  showsTestAd: false,
                  iOSAdUnitID: 'ca-app-pub-7880697829268273/6177072322',
                  androidAdUnitID: 'ca-app-pub-7880697829268273/5581116466',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
