import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/core/mixins/notifier_mixin.dart';

class _Host extends StatefulWidget {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> with NotifierMixin {
  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}

void main() {
  late NotifierService notifier;

  setUp(() async {
    await GetIt.I.reset();
    notifier = NotifierService();
    GetIt.I.registerSingleton(notifier);
  });

  tearDown(() => GetIt.I.reset());

  Future<void> pumpHost(WidgetTester tester, Locale locale) => tester.pumpWidget(MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const _Host(),
      ));

  for (final (locale, text) in [
    (const Locale('en'), "Your change couldn't be saved. Nothing was changed."),
    (const Locale('es'), 'No se pudo guardar el cambio. No se modificó nada.'),
  ]) {
    testWidgets('a repository notice is shown in ${locale.languageCode}', (tester) async {
      await pumpHost(tester, locale);

      notifier.notifyChangeNotSaved();
      await tester.pump();

      expect(find.text(text), findsOneWidget);
      expect(tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor, Colors.redAccent,
          reason: 'it is an error');
    });
  }

  testWidgets('a plain notice replaces a localized one nobody has shown', (tester) async {
    notifier.notifyChangeNotSaved();
    notifier.notify('Account Main added successfully');
    await pumpHost(tester, const Locale('en'));
    notifier.notify('Account Main added successfully');
    await tester.pump();

    expect(find.text('Account Main added successfully'), findsOneWidget);
    expect(find.textContaining("couldn't be saved"), findsNothing);
    expect(tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor, Colors.greenAccent);
  });

  testWidgets('plain notices still work', (tester) async {
    await pumpHost(tester, const Locale('en'));

    notifier.notify('Account Main added successfully');
    await tester.pump();

    expect(find.text('Account Main added successfully'), findsOneWidget);
  });
}
