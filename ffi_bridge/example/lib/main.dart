import 'dart:async';

import 'package:circuit_solver_proto/circuit_solver_proto.dart';
import 'package:ffi_bridge/ffi_bridge.dart' as ffi_bridge;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: _CircuitSolverDemo());
  }
}

/// Demonstrates solving a simple series circuit (5 V + 2 Ω + 3 Ω) via the
/// ffi_bridge package.
class _CircuitSolverDemo extends StatefulWidget {
  const _CircuitSolverDemo();

  @override
  State<_CircuitSolverDemo> createState() => _CircuitSolverDemoState();
}

class _CircuitSolverDemoState extends State<_CircuitSolverDemo> {
  late final Future<CircuitGraphMessage> _solveFuture;

  @override
  void initState() {
    super.initState();
    _solveFuture = ffi_bridge.solveCircuit(_buildSeriesCircuit());
  }

  /// Builds the unsolved 5 V source + 2 Ω + 3 Ω series circuit.
  CircuitGraphMessage _buildSeriesCircuit() {
    const String v0Id = 'v0';
    const String v1Id = 'v1';
    const String v2Id = 'v2';

    return CircuitGraphMessage(
      vertices: {
        v0Id: CircuitGraphMessage_Vertex(id: v0Id, voltage: 0),
        v1Id: CircuitGraphMessage_Vertex(id: v1Id),
        v2Id: CircuitGraphMessage_Vertex(id: v2Id),
      }.entries,
      edges: {
        'e0': CircuitGraphMessage_Edge(
          id: 'e0',
          fromId: v0Id,
          toId: v1Id,
          voltageSource: CircuitGraphMessage_Edge_VoltageSource(voltage: 5),
        ),
        'e1': CircuitGraphMessage_Edge(
          id: 'e1',
          fromId: v1Id,
          toId: v2Id,
          resistor: CircuitGraphMessage_Edge_Resistor(resistance: 2),
        ),
        'e2': CircuitGraphMessage_Edge(
          id: 'e2',
          fromId: v2Id,
          toId: v0Id,
          resistor: CircuitGraphMessage_Edge_Resistor(resistance: 3),
        ),
      }.entries,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Circuit Solver FFI Demo')),
      body: FutureBuilder<CircuitGraphMessage>(
        future: _solveFuture,
        builder:
            (
              BuildContext context,
              AsyncSnapshot<CircuitGraphMessage> snapshot,
            ) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final CircuitGraphMessage result = snapshot.data!;
              return _SolvedCircuitView(result: result);
            },
      ),
    );
  }
}

class _SolvedCircuitView extends StatelessWidget {
  const _SolvedCircuitView({required this.result});

  final CircuitGraphMessage result;

  @override
  Widget build(BuildContext context) {
    const TextStyle labelStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
    const TextStyle valueStyle = TextStyle(fontSize: 16);
    const SizedBox spacer = SizedBox(height: 8);

    final List<Widget> rows = [
      const Text('Series circuit: 5 V + 2 Ω + 3 Ω', style: labelStyle),
      spacer,
      ...result.vertices.entries.map(
        (e) => Text(
          '${e.key}: ${e.value.voltage.toStringAsFixed(3)} V',
          style: valueStyle,
        ),
      ),
      spacer,
      ...result.edges.entries.map(
        (e) => Text(
          '${e.key}: ${e.value.current.toStringAsFixed(3)} A',
          style: valueStyle,
        ),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }
}
