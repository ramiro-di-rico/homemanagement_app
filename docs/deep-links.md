# Deep Links

This app now supports invite links in three forms:

- Web/App Link: `https://www.ramiro-di-rico.dev/public/invites/{token}`
- Android App Link: verified from the same HTTPS URL once `assetlinks.json` is configured
- Native fallback scheme: `homemanagementapp://public/invites/{token}`

## Flutter behavior

- Incoming links are handled by `lib/services/deep_link_service.dart`
- Supported route target: `/public/invites/{token}`

## Android

Configured in `android/app/src/main/AndroidManifest.xml`.

To enable verified App Links in production:

1. Keep the final `applicationId` stable.
2. Replace `REPLACE_WITH_RELEASE_SHA256_CERT_FINGERPRINT` in `web/.well-known/assetlinks.json`.
3. Host that file at:
   `https://www.ramiro-di-rico.dev/.well-known/assetlinks.json`

## iOS

Configured with:

- `ios/Runner/Runner.entitlements`
- `ios/Runner/Info.plist`

To enable Universal Links in production:

1. Replace `REPLACE_WITH_TEAM_ID.com.example.homemanagementApp` in `web/.well-known/apple-app-site-association`
2. Use the real Apple Team ID and final bundle identifier.
3. Host the file at:
   `https://www.ramiro-di-rico.dev/.well-known/apple-app-site-association`
4. Ensure the iOS app is signed with the matching App ID.

## Important

The project still uses placeholder package identifiers:

- Android: `com.example.home_management_app`
- iOS: `com.example.homemanagementApp`

Verified mobile deep links will only work on devices once these are replaced with your real production IDs and the `.well-known` files are updated to match.
