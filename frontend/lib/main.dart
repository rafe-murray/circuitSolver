import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/ui/widgets/component_painter.dart';
import 'package:frontend/ui/widgets/editor_screen.dart';
// import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// import 'commands/command.dart';
import 'data/model/circuit_models.dart';
// import 'screens/editor_page.dart';
// import 'screens/landing_page.dart';
import 'services/storage.dart';
// import 'viewmodels/canvas_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CircuitSolverApp()));
}

class CircuitSolverApp extends StatelessWidget {
  const CircuitSolverApp({super.key});

  @override
  Widget build(BuildContext context) {
    final uuid = Uuid();
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: Column(
        children: [
          Text("Hello, world!"),
          Container(
            color: Colors.white,
            child: EditorScreen(circuitId: uuid.v7obj()),
          ),
        ],
      ),
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
