import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = true;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => appStateNotifier.showSplashImage
          ? Builder(
              builder: (context) => Container(
                color: Colors.transparent,
                child: Image.asset(
                  'assets/images/image_39501536-D962-4CC5-824F-E68F7E61E3FA_1777254460.png',
                  fit: BoxFit.fill,
                ),
              ),
            )
          : HomeMenuWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => appStateNotifier.showSplashImage
              ? Builder(
                  builder: (context) => Container(
                    color: Colors.transparent,
                    child: Image.asset(
                      'assets/images/image_39501536-D962-4CC5-824F-E68F7E61E3FA_1777254460.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                )
              : HomeMenuWidget(),
        ),
        FFRoute(
          name: HomePageXPLANEWidget.routeName,
          path: HomePageXPLANEWidget.routePath,
          builder: (context, params) => HomePageXPLANEWidget(),
        ),
        FFRoute(
          name: TOCalculationWidget.routeName,
          path: TOCalculationWidget.routePath,
          builder: (context, params) => TOCalculationWidget(
            v1Val: params.getParam(
              'v1Val',
              ParamType.int,
            ),
            vRVal: params.getParam(
              'vRVal',
              ParamType.int,
            ),
            v2Val: params.getParam(
              'v2Val',
              ParamType.int,
            ),
            flexVal: params.getParam(
              'flexVal',
              ParamType.String,
            ),
            fSpeed: params.getParam(
              'fSpeed',
              ParamType.int,
            ),
            sSpeed: params.getParam(
              'sSpeed',
              ParamType.int,
            ),
            oSpeed: params.getParam(
              'oSpeed',
              ParamType.int,
            ),
            thsVal: params.getParam(
              'thsVal',
              ParamType.String,
            ),
            eoACC: params.getParam(
              'eoACC',
              ParamType.double,
            ),
            isSafe: params.getParam(
              'isSafe',
              ParamType.bool,
            ),
          ),
        ),
        FFRoute(
          name: LDGCalculationWidget.routeName,
          path: LDGCalculationWidget.routePath,
          builder: (context, params) => LDGCalculationWidget(
            vapp: params.getParam(
              'vapp',
              ParamType.double,
            ),
            vls: params.getParam(
              'vls',
              ParamType.double,
            ),
            actualDistance: params.getParam(
              'actualDistance',
              ParamType.double,
            ),
            oSpeedL: params.getParam(
              'oSpeedL',
              ParamType.double,
            ),
            sSpeedL: params.getParam(
              'sSpeedL',
              ParamType.double,
            ),
            fSpeedL: params.getParam(
              'fSpeedL',
              ParamType.double,
            ),
            qnhL: params.getParam(
              'qnhL',
              ParamType.double,
            ),
            tempL: params.getParam(
              'tempL',
              ParamType.String,
            ),
            windL: params.getParam(
              'windL',
              ParamType.String,
            ),
            ldgConfigL: params.getParam(
              'ldgConfigL',
              ParamType.String,
            ),
            safeL: params.getParam(
              'safeL',
              ParamType.bool,
            ),
            runwatStatusL: params.getParam(
              'runwatStatusL',
              ParamType.String,
            ),
            runwayRemainingL: params.getParam(
              'runwayRemainingL',
              ParamType.String,
            ),
            forcedDistanceL: params.getParam(
              'forcedDistanceL',
              ParamType.double,
            ),
            isSafe: params.getParam(
              'isSafe',
              ParamType.bool,
            ),
          ),
        ),
        FFRoute(
          name: FlightplanpageWidget.routeName,
          path: FlightplanpageWidget.routePath,
          builder: (context, params) => FlightplanpageWidget(),
        ),
        FFRoute(
          name: IPpageXplaneWidget.routeName,
          path: IPpageXplaneWidget.routePath,
          builder: (context, params) => IPpageXplaneWidget(),
        ),
        FFRoute(
          name: TermsOFuseWidget.routeName,
          path: TermsOFuseWidget.routePath,
          builder: (context, params) => TermsOFuseWidget(),
        ),
        FFRoute(
          name: PrivacyPolicyPageWidget.routeName,
          path: PrivacyPolicyPageWidget.routePath,
          builder: (context, params) => PrivacyPolicyPageWidget(),
        ),
        FFRoute(
          name: WebWidget.routeName,
          path: WebWidget.routePath,
          builder: (context, params) => WebWidget(),
        ),
        FFRoute(
          name: SubscribeXplaneWidget.routeName,
          path: SubscribeXplaneWidget.routePath,
          builder: (context, params) => SubscribeXplaneWidget(),
        ),
        FFRoute(
          name: AbouttWidget.routeName,
          path: AbouttWidget.routePath,
          builder: (context, params) => AbouttWidget(),
        ),
        FFRoute(
          name: RefundWidget.routeName,
          path: RefundWidget.routePath,
          builder: (context, params) => RefundWidget(),
        ),
        FFRoute(
          name: MsfsWidget.routeName,
          path: MsfsWidget.routePath,
          builder: (context, params) => MsfsWidget(),
        ),
        FFRoute(
          name: HomePageMSFSWidget.routeName,
          path: HomePageMSFSWidget.routePath,
          builder: (context, params) => HomePageMSFSWidget(),
        ),
        FFRoute(
          name: HomeMenuWidget.routeName,
          path: HomeMenuWidget.routePath,
          builder: (context, params) => HomeMenuWidget(),
        ),
        FFRoute(
          name: IPpageMSFSWidget.routeName,
          path: IPpageMSFSWidget.routePath,
          builder: (context, params) => IPpageMSFSWidget(),
        ),
        FFRoute(
          name: SubscribeMSFSWidget.routeName,
          path: SubscribeMSFSWidget.routePath,
          builder: (context, params) => SubscribeMSFSWidget(),
        ),
        FFRoute(
          name: SubscribePackageXplaneMSFSWidget.routeName,
          path: SubscribePackageXplaneMSFSWidget.routePath,
          builder: (context, params) => SubscribePackageXplaneMSFSWidget(),
        ),
        FFRoute(
          name: SubscriptionManagepageMSFSmounthlyWidget.routeName,
          path: SubscriptionManagepageMSFSmounthlyWidget.routePath,
          builder: (context, params) =>
              SubscriptionManagepageMSFSmounthlyWidget(),
        ),
        FFRoute(
          name: SubscriptionManagepageMSFSyearlyWidget.routeName,
          path: SubscriptionManagepageMSFSyearlyWidget.routePath,
          builder: (context, params) =>
              SubscriptionManagepageMSFSyearlyWidget(),
        ),
        FFRoute(
          name: SubscriptionManagepageMSFSlifetimeWidget.routeName,
          path: SubscriptionManagepageMSFSlifetimeWidget.routePath,
          builder: (context, params) =>
              SubscriptionManagepageMSFSlifetimeWidget(),
        ),
        FFRoute(
          name: SubscriptionManagepageWidget.routeName,
          path: SubscriptionManagepageWidget.routePath,
          builder: (context, params) => SubscriptionManagepageWidget(),
        ),
        FFRoute(
          name: SubscriptionManagepageXplaneYearlyWidget.routeName,
          path: SubscriptionManagepageXplaneYearlyWidget.routePath,
          builder: (context, params) =>
              SubscriptionManagepageXplaneYearlyWidget(),
        ),
        FFRoute(
          name: SubscriptionManagepageXplaneLifetimeWidget.routeName,
          path: SubscriptionManagepageXplaneLifetimeWidget.routePath,
          builder: (context, params) =>
              SubscriptionManagepageXplaneLifetimeWidget(),
        ),
        FFRoute(
          name: SubscriptionManagepageAllsimMonthlyWidget.routeName,
          path: SubscriptionManagepageAllsimMonthlyWidget.routePath,
          builder: (context, params) =>
              SubscriptionManagepageAllsimMonthlyWidget(),
        ),
        FFRoute(
          name: SubscriptionManagepageAllsimYearlyWidget.routeName,
          path: SubscriptionManagepageAllsimYearlyWidget.routePath,
          builder: (context, params) =>
              SubscriptionManagepageAllsimYearlyWidget(),
        ),
        FFRoute(
          name: SubscriptionManageForALLWidget.routeName,
          path: SubscriptionManageForALLWidget.routePath,
          builder: (context, params) => SubscriptionManageForALLWidget(),
        ),
        FFRoute(
          name: PdfmsfsquideWidget.routeName,
          path: PdfmsfsquideWidget.routePath,
          builder: (context, params) => PdfmsfsquideWidget(),
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
