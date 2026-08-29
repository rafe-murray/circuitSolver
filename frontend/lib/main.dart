import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/ui/widgets/editor_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'ui/widgets/home_screen.dart';

part 'main.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CircuitSolverApp()));
}

final _router = GoRouter(routes: $appRoutes);

@TypedGoRoute<HomeScreenRoute>(
  path: '/',
  routes: [TypedGoRoute<CircuitEditorRoute>(path: 'edit/:circuitId')],
)
@immutable
class HomeScreenRoute extends GoRouteData with $HomeScreenRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomeScreen();
  }
}

@immutable
class CircuitEditorRoute extends GoRouteData with $CircuitEditorRoute {
  final String circuitId;
  const CircuitEditorRoute({required this.circuitId});
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return EditorScreen(circuitId: UuidValue.withValidation(circuitId));
  }
}

class CircuitSolverApp extends StatelessWidget {
  const CircuitSolverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(colorSchemeSeed: Colors.cyan),
      routerConfig: _router,
    );
    // return MultiProvider(
    //   providers: [
    //     Provider<StorageService>.value(value: storage),
    //     ChangeNotifierProvider<HistoryStack>(create: (_) => HistoryStack()),
    //     ChangeNotifierProvider<CanvasViewModel>(
    //       create: (_) => CanvasViewModel(),
    //     ),
    //   ],
    //   child: MaterialApp(
    //     title: 'Circuit Solver',
    //     theme: ThemeData(
    //       colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    //       useMaterial3: true,
    //     ),
    //     initialRoute: '/',
    //     routes: {
    //       '/': (_) => const LandingPage(),
    //       '/editor': (_) => const EditorPage(),
    //     },
    //   ),
    // );
  }
}
