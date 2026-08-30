import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/circuit_list_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Circuit Solver")),
      body: CircuitListWidget(),
    );
  }
}
