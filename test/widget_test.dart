// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:home_management_app/main.dart';
import 'package:home_management_app/services/infra/platform/platform_strategy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/myapp.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    var platform = PlatformStrategy.createPlatform();
    registerDependencies(platform);
    tester.view.physicalSize = Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.reset());

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(platform));

    // Verify that we are on the login page by checking for the "Sign In" text.
    expect(find.text('Sign In'), findsOneWidget);
  });
}
