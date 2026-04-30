import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:govi_app/main.dart';
import 'package:govi_app/screens/profile/theme_provider.dart';

void main() {
  testWidgets('GOVI app shows startup error when Firebase is unavailable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const GovAppBootstrap(firebaseInitialized: false),
      ),
    );

    expect(find.textContaining('GOVI'), findsOneWidget);
  });
}
