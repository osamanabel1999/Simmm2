// Automatic FlutterFlow imports
import '/flutter_flow/ff_builtin_enums.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class SystemWebView extends StatefulWidget {
  const SystemWebView({
    super.key,
    this.width,
    this.height,
    this.initialUrl,
  });

  final double? width;
  final double? height;
  final String? initialUrl;

  @override
  State<SystemWebView> createState() => _SystemWebViewState();
}

class _SystemWebViewState extends State<SystemWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    // Disable WebView zoom before loading the page.
    await _controller.enableZoom(false);

    await _controller.setJavaScriptMode(
      JavaScriptMode.unrestricted,
    );

    await _controller.setBackgroundColor(
      const Color(0x00000000),
    );

    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onWebResourceError: (WebResourceError error) {
          debugPrint('WebView Error: ${error.description}');
        },
      ),
    );

    final String? url = widget.initialUrl;
    if (url != null && url.isNotEmpty) {
      await _controller.loadRequest(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: WebViewWidget(controller: _controller),
    );
  }
}
