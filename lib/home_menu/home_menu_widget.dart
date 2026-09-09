import '/flutter_flow/flutter_flow_ad_banner.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'home_menu_model.dart';
export 'home_menu_model.dart';

class HomeMenuWidget extends StatefulWidget {
  const HomeMenuWidget({super.key});

  static String routeName = 'HomeMenu';
  static String routePath = '/homeMenu';

  @override
  State<HomeMenuWidget> createState() => _HomeMenuWidgetState();
}

class _HomeMenuWidgetState extends State<HomeMenuWidget> {
  late HomeMenuModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeMenuModel());
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
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: custom_widgets.SimulatorStationHome(
                    width: double.infinity,
                    height: double.infinity,
                    image1:
                        'https://github.com/osamanabel1999/App-assets/blob/main/1C1766C7-00D5-4C6E-B56F-91E6CC8CBBB5.png?raw=true',
                    image2:
                        'https://github.com/osamanabel1999/App-assets/blob/main/1A619D77-16B2-4C46-A052-F9CB16574952.png?raw=true',
                    action1: () async {
                      context.pushNamed(IPpageXplaneWidget.routeName);
                    },
                    action2: () async {
                      context.pushNamed(IPpageMSFSWidget.routeName);
                    },
                  ),
                ),
              ),
              FlutterFlowAdBanner(
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: 50.0,
                showsTestAd: false,
                iOSAdUnitID: 'ca-app-pub-7880697829268273/9930210303',
                androidAdUnitID: 'ca-app-pub-7880697829268273/5581116466',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
