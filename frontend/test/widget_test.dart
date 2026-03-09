import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/services/storage.dart';

void main() {
  testWidgets('Landing page shows New circuit button', (tester) async {
    final storage = await StorageService.createInMemory();
    await tester.pumpWidget(CircuitSolverApp(storage: storage));
    await tester.pumpAndSettle();

    expect(find.text('New circuit'), findsOneWidget);
  });
}
