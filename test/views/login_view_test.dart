import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/services/platform/platform_strategy.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/main.dart';
import 'package:home_management_app/ui/core/custom/components/email-textfield.dart';
import 'package:home_management_app/ui/features/authentication/views/login.dart';
import 'package:home_management_app/ui/features/authentication/views/login-desktop.dart';

void main() {
  setUpAll(() {
    final platform = PlatformStrategy.createPlatform();
    registerDependencies(platform);
  });

  Widget buildTestWidget({
    required Widget child,
    required Size size,
    EdgeInsets viewInsets = EdgeInsets.zero,
  }) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          viewInsets: viewInsets,
        ),
        child: child,
      ),
    );
  }

  testWidgets('LoginView centers content and displays footer when keyboard is closed',
      (WidgetTester tester) async {
    const screenSize = Size(390, 844);
    tester.view.physicalSize = screenSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildTestWidget(
        child: LoginView(),
        size: screenSize,
        viewInsets: EdgeInsets.zero,
      ),
    );
    await tester.pump();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(EmailTextField), findsOneWidget);
    expect(find.text("You don't have an account yet ?"), findsOneWidget);
    expect(find.text('Create one'), findsOneWidget);

    final emailTopBefore = tester.getTopLeft(find.byType(EmailTextField)).dy;
    expect(emailTopBefore, greaterThan(200));
  });

  testWidgets('LoginView shifts to the top and hides footer when keyboard appears on mobile',
      (WidgetTester tester) async {
    const screenSize = Size(390, 844);
    tester.view.physicalSize = screenSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildTestWidget(
        child: LoginView(),
        size: screenSize,
        viewInsets: const EdgeInsets.only(bottom: 340),
      ),
    );
    await tester.pump();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(EmailTextField), findsOneWidget);

    final emailTopWithKeyboard =
        tester.getTopLeft(find.byType(EmailTextField)).dy;
    // With 340px keyboard, the form moves to the top area (close to AppBar)
    expect(emailTopWithKeyboard, lessThan(160));

    // Footer is hidden when keyboard is open
    expect(find.text("You don't have an account yet ?"), findsNothing);
    expect(find.text('Create one'), findsNothing);

    // Scroll view is present to allow scrolling without RenderFlex overflow
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('DesktopLoginView shifts up and scrolls when keyboard appears on mobile viewport',
      (WidgetTester tester) async {
    const screenSize = Size(390, 844);
    tester.view.physicalSize = screenSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildTestWidget(
        child: const DesktopLoginView(),
        size: screenSize,
        viewInsets: const EdgeInsets.only(bottom: 340),
      ),
    );
    await tester.pump();

    expect(find.byType(DesktopLoginView), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);

    final emailTop = tester.getTopLeft(find.byType(EmailTextField)).dy;
    expect(emailTop, lessThan(200));
  });
}
