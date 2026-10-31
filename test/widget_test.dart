// Basic smoke test untuk aplikasi Crypto Tracker.
// Memastikan aplikasi dapat dibangun dan judul AppBar muncul.

import 'package:flutter_test/flutter_test.dart';

import 'package:crypto_tracker/main.dart';

void main() {
  testWidgets('Crypto Tracker app renders title and Refresh button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CryptoTrackerApp());

    expect(find.text('Crypto Tracker'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
  });
}
