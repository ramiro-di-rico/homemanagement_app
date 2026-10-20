import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/local/local_database_opener.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/platform/platform_strategy.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/main.dart';
import 'package:home_management_app/myapp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_platform.dart';

void main() {
  testWidgets('an unreadable local file does not lock the user out of the app', (tester) async {
    SharedPreferences.setMockInitialValues({'appMode': 'local'});
    await GetIt.I.reset();
    addTearDown(GetIt.I.reset);
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final appMode = AppModeService(FakePlatform(PlatformType.Desktop),
        openDatabase: (_, {required mustExist}) async =>
            throw LocalDataUnavailableException(LocalDataUnavailableReason.keyMissing));
    await appMode.init();
    final platform = PlatformStrategy.createPlatform();
    registerDependencies(platform, appModeService: appMode);

    await tester.pumpWidget(MyApp(platform));
    await tester.pumpAndSettle();

    expect(find.text("Your local data can't be opened"), findsOneWidget);
    expect(find.text('Sign In'), findsNothing);

    await tester.tap(find.text('Use an online account instead'));
    await tester.pumpAndSettle();

    expect(find.text("Your local data can't be opened"), findsNothing);
    expect(find.text('Sign In'), findsOneWidget, reason: 'the login screen of the online app');
    expect(appMode.isLocal, isFalse);
  });
}
