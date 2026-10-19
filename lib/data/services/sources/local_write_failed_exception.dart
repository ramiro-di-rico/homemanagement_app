/// A write to the local database failed (for example the disk is full), so the
/// change was not saved. Nothing was changed.
class LocalWriteFailedException implements Exception {
  final Object? cause;

  LocalWriteFailedException([this.cause]);

  @override
  String toString() => 'LocalWriteFailedException(${cause ?? ''})';
}
