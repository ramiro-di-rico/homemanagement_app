import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/repositories/identity_user_repository.dart';
import 'package:home_management_app/data/repositories/reminder_repository.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/domain/models/reminder.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/authentication/view_models/my_user_view_model.dart';
import 'package:home_management_app/ui/features/settings/views/settings-widgets/reminders/notification_preferences_widget.dart';
import 'package:home_management_app/ui/features/settings/views/settings-widgets/reminders/reminders_desktop_view.dart';
import 'package:home_management_app/ui/features/settings/views/settings-widgets/reminders/reminders_list_content.dart';

class FakeReminderRepository extends ChangeNotifier implements ReminderRepository {
  List<Reminder> _reminders;
  final bool _isLoading = false;

  FakeReminderRepository(this._reminders);

  @override
  List<Reminder> get reminders => _reminders;

  @override
  bool get isLoading => _isLoading;

  void setReminders(List<Reminder> newReminders) {
    _reminders = newReminders;
    notifyListeners();
  }

  @override
  Future<List<Reminder>> getReminders({bool forceRefresh = false}) async {
    return _reminders;
  }

  @override
  Future<Map<String, dynamic>> getNotificationPreferences() async {
    return {
      'digestFrequency': 1,
      'preferredSendTime': '09:00:00',
    };
  }

  @override
  Future<void> setAllCompleted(bool completed) async {
    _reminders = _reminders
        .map((r) => Reminder(
              r.id,
              r.title,
              r.startDate,
              r.endDate,
              r.frequency,
              r.notifyByEmail,
              completed,
              r.snoozedUntil,
            ))
        .toList();
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeIdentityUserRepository extends ChangeNotifier
    implements IdentityUserRepository {
  final MyUserViewModel? _user;

  FakeIdentityUserRepository([this._user]);

  @override
  MyUserViewModel? get currentUser => _user;

  @override
  Future<MyUserViewModel?> getUser() async => _user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeReminderRepository fakeReminderRepository;
  late FakeIdentityUserRepository fakeIdentityUserRepository;

  final sampleReminders = [
    Reminder(
      1,
      'Pay electric bill',
      DateTime(2026, 1, 1),
      null,
      Frequency.monthly,
      true,
      false,
    ),
    Reminder(
      2,
      'Renew car insurance',
      DateTime(2026, 1, 1),
      null,
      Frequency.yearly,
      false,
      false,
      DateTime.now().add(const Duration(days: 3)), // Snoozed
    ),
    Reminder(
      3,
      'Water the plants',
      DateTime(2026, 1, 1),
      null,
      Frequency.daily,
      false,
      true, // Completed
    ),
  ];

  setUp(() {
    fakeReminderRepository = FakeReminderRepository(List.from(sampleReminders));
    fakeIdentityUserRepository = FakeIdentityUserRepository(
      MyUserViewModel(
        id: 'user-1',
        email: 'test@example.com',
        digestFrequency: 1,
        preferredSendTime: '08:30:00',
      ),
    );

    if (GetIt.I.isRegistered<ReminderRepository>()) {
      GetIt.I.unregister<ReminderRepository>();
    }
    if (GetIt.I.isRegistered<IdentityUserRepository>()) {
      GetIt.I.unregister<IdentityUserRepository>();
    }
    if (GetIt.I.isRegistered<NotifierService>()) {
      GetIt.I.unregister<NotifierService>();
    }

    GetIt.I.registerSingleton<ReminderRepository>(fakeReminderRepository);
    GetIt.I.registerSingleton<IdentityUserRepository>(fakeIdentityUserRepository);
    GetIt.I.registerSingleton<NotifierService>(NotifierService());
  });

  tearDown(() {
    if (GetIt.I.isRegistered<ReminderRepository>()) {
      GetIt.I.unregister<ReminderRepository>();
    }
    if (GetIt.I.isRegistered<IdentityUserRepository>()) {
      GetIt.I.unregister<IdentityUserRepository>();
    }
    if (GetIt.I.isRegistered<NotifierService>()) {
      GetIt.I.unregister<NotifierService>();
    }
  });

  Widget createSubject({Size size = const Size(1280, 800)}) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RemindersDesktopView(),
      ),
    );
  }

  testWidgets('renders RemindersDesktopView with title, overview card and panes',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    // Verify title and main sections
    expect(find.text('Reminders'), findsAtLeastNWidgets(1));
    expect(find.text('Reminders Overview'), findsOneWidget);
    expect(find.byType(ReminderListContent), findsOneWidget);
    expect(find.byType(NotificationPreferencesWidget), findsOneWidget);

    // Verify summary metric values
    // 1 pending, 1 snoozed, 1 completed, 3 total
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Snoozed'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('3'), findsOneWidget); // Total count

    // Reminders are shown in the list
    expect(find.text('Pay electric bill'), findsOneWidget);
    expect(find.text('Renew car insurance'), findsOneWidget);
    expect(find.text('Water the plants'), findsOneWidget);
  });

  testWidgets('summary metrics update dynamically when reminders change',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    // Initially total is 3
    expect(find.text('3'), findsOneWidget);

    // Mark all as completed via repository
    await fakeReminderRepository.setAllCompleted(true);
    await tester.pumpAndSettle();

    // Completed should now be 3, Pending 0, Snoozed 0
    expect(find.text('3'), findsNWidgets(2)); // Total is 3, Completed is 3
  });

  testWidgets('renders properly in narrower/compact desktop window',
      (tester) async {
    tester.view.physicalSize = const Size(800, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createSubject(size: const Size(800, 700)));
    await tester.pumpAndSettle();

    expect(find.text('Reminders Overview'), findsOneWidget);
    expect(find.byType(ReminderListContent), findsOneWidget);
    expect(find.byType(NotificationPreferencesWidget), findsOneWidget);
  });
}
