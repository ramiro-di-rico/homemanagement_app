import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/repositories/identity_user_repository.dart';
import 'package:home_management_app/data/repositories/user.repository.dart';
import 'package:home_management_app/data/services/identity_user_service.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/settings/views/settings-widgets/local_preferences_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoServer implements IdentityUserService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('reached the server');
}

void main() {
  late IdentityUserRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    repository = IdentityUserRepository(_NoServer(), UserRepository());
    GetIt.I.registerSingleton<IdentityUserRepository>(repository);
  });

  tearDown(() => GetIt.I.reset());

  Future<void> pump(WidgetTester tester) async {
    // The test font draws every glyph as wide as it is tall, so "Portuguese" would
    // not fit the 150 px dropdown that a real font fits with room to spare.
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.5)),
        child: child!,
      ),
      home: const Scaffold(body: LocalPreferencesWidget()),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, {required String from, required String option}) async {
    await tester.tap(find.text(from));
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  testWidgets('the language chosen is applied and saved, with no server call', (tester) async {
    await pump(tester);

    await choose(tester, from: 'English', option: 'Italian');

    expect(repository.getCurrentLanguage(), 'it');
    expect((await SharedPreferences.getInstance()).getString(IdentityUserRepository.languageKey), 'it');
  });

  testWidgets('the theme chosen is applied and saved', (tester) async {
    await pump(tester);

    await choose(tester, from: 'System', option: 'Dark');

    expect(repository.themeMode, ThemeMode.dark);
    expect((await SharedPreferences.getInstance()).getInt(IdentityUserRepository.themeModeKey),
        ThemeMode.dark.index);
  });

  testWidgets('it shows what was saved before, after a restart', (tester) async {
    SharedPreferences.setMockInitialValues({
      IdentityUserRepository.themeModeKey: ThemeMode.light.index,
      IdentityUserRepository.languageKey: 'pt',
    });
    await repository.loadPreferences();

    await pump(tester);

    expect(find.text('Portuguese'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
  });
}
