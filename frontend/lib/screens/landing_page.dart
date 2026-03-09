import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/storage.dart';
import '../viewmodels/canvas_viewmodel.dart';
import '../viewmodels/landing_viewmodel.dart';

/// The application landing page.
///
/// Shows a list of saved circuits with options to open or delete each one.
/// Also provides a button to open a blank editor session.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  LandingViewModel? _vm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // StorageService is provided above us in the widget tree (see main.dart).
    if (_vm == null) {
      final storage = Provider.of<StorageService>(context, listen: false);
      _vm = LandingViewModel(storage: storage);
    }
  }

  @override
  void dispose() {
    _vm?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm!,
      builder: (context, _) => _LandingView(vm: _vm!),
    );
  }
}

class _LandingView extends StatelessWidget {
  const _LandingView({required this.vm});

  final LandingViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circuit Solver'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: vm.reload,
          ),
        ],
      ),
      body: Column(
        children: [
          _NewCircuitBanner(vm: vm),
          const Divider(height: 1),
          Expanded(child: _CircuitList(vm: vm)),
        ],
      ),
    );
  }
}

class _NewCircuitBanner extends StatelessWidget {
  const _NewCircuitBanner({required this.vm});

  final LandingViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Circuits',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Open a saved circuit or start a new one.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => _openBlankEditor(context),
            icon: const Icon(Icons.add),
            label: const Text('New circuit'),
          ),
        ],
      ),
    );
  }

  void _openBlankEditor(BuildContext context) {
    final canvasVm = Provider.of<CanvasViewModel>(context, listen: false);
    canvasVm.clearCanvas();
    Navigator.pushNamed(context, '/editor').then((_) => vm.reload());
  }
}

class _CircuitList extends StatelessWidget {
  const _CircuitList({required this.vm});

  final LandingViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null) {
      return Center(child: Text('Error: ${vm.error}'));
    }

    if (vm.circuits.isEmpty) {
      return Center(
        child: Text(
          'No saved circuits yet.\nCreate your first one!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: vm.circuits.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final circuit = vm.circuits[index];
        return _CircuitTile(circuit: circuit, vm: vm);
      },
    );
  }
}

class _CircuitTile extends StatelessWidget {
  const _CircuitTile({required this.circuit, required this.vm});

  final Circuit circuit;
  final LandingViewModel vm;

  @override
  Widget build(BuildContext context) {
    final modified = circuit.modifiedAt ?? circuit.createdAt;
    final subtitle = _formatDate(modified);

    return ListTile(
      leading: const Icon(Icons.electrical_services),
      title: Text(circuit.name),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => _openCircuit(context),
    );
  }

  Future<void> _openCircuit(BuildContext context) async {
    final canvasVm = Provider.of<CanvasViewModel>(context, listen: false);
    final loaded = await vm.getCircuit(circuit.id);
    if (loaded == null) return;
    canvasVm.loadFromCircuit(loaded);
    if (!context.mounted) return;
    Navigator.pushNamed(context, '/editor').then((_) => vm.reload());
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete circuit?'),
        content: Text('This will permanently delete "${circuit.name}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await vm.deleteCircuit(circuit.id);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
