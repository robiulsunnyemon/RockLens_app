import 'package:flutter_test/flutter_test.dart';
import 'package:rocklens_app/app/core/values/app_strings.dart';
import 'package:rocklens_app/rocklens_app.dart';

void main() {
  testWidgets('App renders splash screen initially smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RockLensApp());
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.appTagline), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });
}

