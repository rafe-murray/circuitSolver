// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$homeScreenRoute];

RouteBase get $homeScreenRoute => GoRouteData.$route(
  path: '/',
  hasOverriddenOnExit: false,
  factory: $HomeScreenRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'edit/:circuitId',
      hasOverriddenOnExit: false,
      factory: $CircuitEditorRoute._fromState,
    ),
  ],
);

mixin $HomeScreenRoute on GoRouteData {
  static HomeScreenRoute _fromState(GoRouterState state) => HomeScreenRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $CircuitEditorRoute on GoRouteData {
  static CircuitEditorRoute _fromState(GoRouterState state) =>
      CircuitEditorRoute(circuitId: state.pathParameters['circuitId']!);

  CircuitEditorRoute get _self => this as CircuitEditorRoute;

  @override
  String get location =>
      GoRouteData.$location('/edit/${Uri.encodeComponent(_self.circuitId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
