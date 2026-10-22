/// Reading the local database failed because the storage did (an I/O error, a
/// corrupt file). Nothing was changed. The counterpart of
/// `LocalWriteFailedException`, so a read never reaches a screen as a raw database
/// error.
class LocalReadFailedException implements Exception {
  final Object? cause;

  LocalReadFailedException([this.cause]);

  @override
  String toString() => 'LocalReadFailedException(${cause ?? ''})';
}
