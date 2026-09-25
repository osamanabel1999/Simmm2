import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'e_f_bxplane_model.dart';
export 'e_f_bxplane_model.dart';

class EFBxplaneWidget extends StatefulWidget {
  const EFBxplaneWidget({super.key});

  static String routeName = 'EFBxplane';
  static String routePath = '/eFBxplane';

  @override
  State<EFBxplaneWidget> createState() => _EFBxplaneWidgetState();
}

class _EFBxplaneWidgetState extends State<EFBxplaneWidget> {
  late EFBxplaneModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EFBxplaneModel());
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
        backgroundColor: Color(0xFF0B111A),
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: custom_widgets.EfbHomeScreenXplane(
              width: double.infinity,
              height: double.infinity,
              wallpaperUrl:
                  'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/0B235E9F-F201-4F3D-9427-B0C9F254C522.png',
              iconAirportWx:
                  'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/3A9717E3-7FE6-419C-BA85-42E69E2B60E6.png',
              iconWxCharts:
                  'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/DFEF7F05-42D4-4615-A771-F20C2510FBE3.png',
              iconNotams:
                  'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/46AB4E4F-D38B-435F-9730-D3C5EFCB39BD.png',
              iconScratchpad:
                  'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/8B4CF9FB-FB3B-4E14-94F9-8433F4161703.png',
              iconSettings:
                  'https://raw.githubusercontent.com/osamanabel1999/App-assets/refs/heads/main/IMG_2364.jpeg',
              simbriefUserId: FFAppState().SimbreifID.toString(),
              onExitAction: () async {
                context.pushNamed(HomePageXPLANEWidget.routeName);
              },
              onSettingsAction: () async {
                FFAppState().TabNumber = 13;
                safeSetState(() {});

                context.pushNamed(HomePageXPLANEWidget.routeName);
              },
            ),
          ),
        ),
      ),
    );
  }
}
