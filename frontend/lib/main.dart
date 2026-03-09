import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/editor_page.dart';
import 'screens/landing_page.dart';
import 'services/storage.dart';
import 'viewmodels/canvas_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.create();
  runApp(CircuitSolverApp(storage: storage));
}

class CircuitSolverApp extends StatelessWidget {
  const CircuitSolverApp({super.key, required this.storage});

  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        ChangeNotifierProvider<CanvasViewModel>(
          create: (_) => CanvasViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Circuit Solver',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const LandingPage(),
          '/editor': (_) => const EditorPage(),
        },
      ),
    );
  }
}
