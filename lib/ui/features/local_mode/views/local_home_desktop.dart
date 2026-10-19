import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/repositories/currency.repository.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/accounts/views/account-list-desktop.dart';

/// The desktop home in local mode. It replaces `HomeDesktop` rather than
/// branching inside it, so the online home stays untouched.
///
/// Only what works without a server is here: no dashboard, reminders, tags,
/// budget or user profile. Local mode makes no network calls (FR-004).
class LocalHomeDesktop extends StatefulWidget {
  const LocalHomeDesktop({super.key});

  @override
  State<LocalHomeDesktop> createState() => _LocalHomeDesktopState();
}

class _LocalHomeDesktopState extends State<LocalHomeDesktop> {
  @override
  void initState() {
    super.initState();
    GetIt.I<AccountRepository>().load();
    GetIt.I<CurrencyRepository>().load();
    GetIt.I<CategoryRepository>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AccountListDesktopView(),
            ),
          ),
        ),
      ),
    );
  }
}
