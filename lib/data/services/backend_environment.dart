/// Origin that all backend APIs (home management, identity, reminders) are served
/// under, each on its own path prefix. Defaults to production; override for a local
/// stack with `--dart-define=BACKEND_ORIGIN=http://localhost:8088`.
class BackendEnvironment {
  static const String origin = String.fromEnvironment(
    'BACKEND_ORIGIN',
    defaultValue: 'https://www.ramiro-di-rico.dev',
  );

  static Uri uri(String path, [Map<String, dynamic>? queryParameters]) =>
      Uri.parse(origin).replace(path: path, queryParameters: queryParameters);
}
