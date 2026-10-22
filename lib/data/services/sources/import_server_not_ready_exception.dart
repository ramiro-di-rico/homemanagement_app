/// The online account exists, but the server hasn't finished creating its default
/// categories and account. It does that after registration, in the background, so
/// the import waits for it. Retrying later is safe: nothing was changed.
class ImportServerNotReadyException implements Exception {
  /// How long the import waited before giving up.
  final Duration waited;

  ImportServerNotReadyException(this.waited);

  @override
  String toString() =>
      'ImportServerNotReadyException: not ready after ${waited.inSeconds} s';
}
