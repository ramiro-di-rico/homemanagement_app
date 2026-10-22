# Quickstart: Validating Standalone Desktop Mode

**Feature**: [spec.md](./spec.md) | **Design**: [data-model.md](./data-model.md), [contracts/](./contracts/)

## Prerequisites

- Flutter 3.47.6, on Linux (primary). Windows and macOS are optional.
- **Linux**: `sudo apt install libsecret-1-dev gnome-keyring`, with a desktop session where the keyring is unlocked.
  - Headless: `eval $(dbus-launch --sh-syntax); echo "" | gnome-keyring-daemon --unlock --daemonize --components=secrets`
- **macOS**: the Keychain Sharing entitlement is present in both `.entitlements` files. Whether it works with ad-hoc signing is **not verified**; see Q18.
- **Import scenarios only**: a backend run locally (`../home-management-all`, docker compose), selected with `--dart-define=BACKEND_ORIGIN=http://localhost:8088`. No backend code changes are needed, but **the new-user event must be processed**: Kafka on (Altair `UseKafka: true`, the `kafka` compose service) and the API's `UserRegistrationKafka` feature enabled. Otherwise the new account never gets its Cash account and default categories, and the import stops with "Your online account isn't ready yet". See `contracts/backend-import.md`.

## Build and automated checks

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenerates local_database.g.dart
flutter gen-l10n
flutter analyze
flutter test                      # includes test/data/local and test/data/services
flutter build linux --release
```

Expected:
- Analyze is clean and all tests pass.
- The release bundle contains the sqlite3mc library under `build/linux/x64/release/bundle/lib/`.

## Manual scenarios

| # | Covers | Steps | Expected |
|---|---|---|---|
| Q1 | US1, FR-001/002/004 | Disconnect the network. Launch the release build. Click **Use without an account** | Home opens with no error. A local-mode banner is shown. No server panels |
| Q2 | FR-001 | Run `flutter run -d chrome` | No "Use without an account" option |
| Q3 | US1-4, FR-003 | Close and relaunch | Opens directly into the local home screen |
| Q4 | US2, FR-005–009 | Create "Wallet" (ARS). Add income 100 and expense 30. Edit the expense to 40. Delete the income | Balance goes 0 → 100 → 70 → 60 → −40 |
| Q5 | R7 | Try to delete a category that is in use, and an account with transactions | Both are blocked with a message. Deactivating the category works |
| Q6 | FR-014, SC-007 | `head -c 16 ~/.local/share/homemanagement_app/homemanagement_local.sqlite` (the folder is named after the binary; `getApplicationSupportDirectory`) | Not `SQLite format 3`. The text of a transaction name does not appear in `strings` of the file |
| Q7 | Edge case "cannot open" | Remove the `local_db_key_v1` secret (seahorse), then relaunch | "Local data cannot be opened" screen. The file is untouched (same size and mtime) |
| Q8 | US3, FR-015/016 | Open each AppBar action, Settings, account detail and the add-transaction sheet. Try `context.go('/home_screen/budget')` via a debug link | Only the allowed features are visible. Hidden routes redirect home |
| Q9 | US4, FR-018–024 | Reconnect. Click **Create account** and register a new email | Progress is shown, then a summary. The app is online. Accounts, categories, transactions and balances match the local data. `homemanagement_local.backup-YYYY-MM-DD.sqlite` exists |
| Q10 | R6 | Before Q9, name a transaction exactly like another local account (e.g. a transaction "Savings" in account "Wallet") | After the import, no extra mirror transaction appears online, all accounts have their real names again (no `⟨import …⟩` suffix), and balances still match |
| Q11 | FR-021, SC-006 | Repeat Q9 on a fresh dataset, but kill the backend halfway through the transaction step. Restart the backend and click **Resume** | It completes. No duplicates (compare the transaction counts per account) |
| Q16 | SP-01 | In local mode with data, create an account, and when the sign-in or the two-factor prompt appears, close the app. Relaunch | Still local, with a banner offering **Finish moving your local data** (not "Create online account"). It opens the login with the email filled in. Signing in (and the 2FA code, if asked) runs the move. Local data can't be edited meanwhile |
| Q17 | SP-02 | Run Q9 right after the backend starts, or with the new-user event paused for ~10 s | The import shows "Waiting for your online account to be ready", then continues. No category is duplicated online. With the event off for longer than 30 s it stops with "isn't ready yet" and **Retry** works once it is on |
| Q18 | RF-17, macOS only | On a Mac: **(1)** `flutter run -d macos` with no signing team set. Does it build, sign and launch? Does online sign-in work? **(2)** Click **Use without an account**. **(3)** Quit and relaunch | **If (1) fails to sign or launch**, the entitlement itself is the problem for every macOS build, online included: remove `keychain-access-groups` from both `.entitlements` files and re-check. **If (2) says local data can't be opened** (Console shows -34018): either set a Development Team in Xcode (Signing & Capabilities) and re-run, or for a development build only run with `--dart-define=MACOS_LEGACY_KEYCHAIN=true`. **If (2) and (3) work**, close RF-17. Do not switch between the two keychains on one machine: a file created under one reports "key missing" under the other, and nothing is deleted. Repeat Q1, Q4, Q6 and Q7 on a build signed with a real team before any macOS release |
| Q12 | FR-026 | Register with an already-used email | You're asked for a different email. Still in local mode, data intact |
| Q13 | Edge case "returning to local" | After Q9, log out and choose **Use without an account** | A new empty dataset (with default categories). The backup file is unchanged |
| Q14 | FR-022 | During Q11, after the failure and before resuming, try to add a transaction and rename a category | Both are blocked with the "finish the move first" message. After resuming, the online data matches the local data exactly |
| Q15 | FR-027 | In local mode with data, choose **Log in to an existing account**, confirm, and log in. Then log out and choose **Use without an account** | The online account shows its own data with nothing moved. Back in local mode, the same local data is there. The option is hidden while an import is pending (during Q11) |

## Performance spot-check (SC-003, SC-004)

Seed 5 accounts and 1,000 transactions using the test helper in `test/data/local/`. Then:
- Check that the balances equal the SQL sums.
- Time Q9. It should take under 2 minutes against a local backend.
