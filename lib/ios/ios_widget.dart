import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ios_model.dart';
export 'ios_model.dart';

class IosWidget extends StatefulWidget {
  const IosWidget({super.key});

  static String routeName = 'IOS';
  static String routePath = '/ios';

  @override
  State<IosWidget> createState() => _IosWidgetState();
}

class _IosWidgetState extends State<IosWidget> {
  late IosModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IosModel());
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
          backgroundColor: Color(0xFF0B111A),
          automaticallyImplyLeading: false,
          title: Text(
            ' ',
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
                  child: custom_widgets.AgoraViewer(
                    width: double.infinity,
                    height: double.infinity,
                    appId: 'cb8d86db8e01476d932b9766b3468481',
                    token:
                        '007eJxTYNhw8RRzLu+6y4rrp09a0yJlYHOt/oeq4yd5E8+n8ybUt4ooMCQnWaRYmKUkWaQaGJqYm6VYGhslWZqbmSUZm5hZmFgYCn/dldUQyMjgqDeBiZEBAkF8Loa0nMz0jJKi/PxcBgYA9YEhBw==',
                    channelName: 'flightroom',
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
