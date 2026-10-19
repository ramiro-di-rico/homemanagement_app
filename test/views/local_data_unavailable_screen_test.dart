import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/local/local_database_opener.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/platform/platform_context.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/local_mode/views/local_data_unavailable_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DesktopPlatform implements PlatformContext {
  @override
  PlatformType getPlatformType() => PlatformType.Desktop;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late LocalDataUnavailableReason? failWith;
  late LocalDatabase? opened;

  Future<AppModeService> failingService() async {
    SharedPreferences.setMockInitialValues({'appMode': 'local'});
    final service = AppModeService(_DesktopPlatform(), openDatabase: (_) async {
      final reason = failWith;
      if (reason != null) throw LocalDataUnavailableException(reason);
      return opened = LocalDatabase(NativeDatabase.memory());
    });
    await service.init();
    return service;
  }

  Widget host(AppModeService service) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LocalDataUnavailableScreen(appModeService: service),
      );

  setUp(() {
    failWith = LocalDataUnavailableReason.keyMissing;
    opened = null;
  });

  tearDown(() async => opened?.close());

  testWidgets('explains the problem and offers only Retry', (tester) async {
    final service = await failingService();
    await tester.pumpWidget(host(service));

    expect(find.text("Your local data can't be opened"), findsOneWidget);
    expect(find.textContaining("hasn't been changed"), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.textContaining(RegExp('delete|reset', caseSensitive: false)), findsNothing);
  });

  testWidgets('a locked keyring gets the keyring explanation', (tester) async {
    failWith = LocalDataUnavailableReason.keyringUnavailable;
    final service = await failingService();
    await tester.pumpWidget(host(service));

    expect(find.textContaining('system keyring'), findsOneWidget);
    expect(find.textContaining("hasn't been changed"), findsNothing);
  });

  testWidgets('Retry runs init again and clears the error when it works', (tester) async {
    final service = await failingService();
    await tester.pumpWidget(host(service));
    expect(service.startupError, isNotNull);

    failWith = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(service.startupError, isNull);
    expect(service.database, isNotNull);
  });
}
