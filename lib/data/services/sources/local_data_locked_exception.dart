import 'package:home_management_app/data/services/sources/local_write_failed_exception.dart';

/// A write was rejected because the local data is being moved to the online
/// account, or the move failed and is not finished yet (FR-022). Nothing was
/// changed. It is a [LocalWriteFailedException], so the places that already treat
/// "not saved" correctly handle it, but the notice says why.
class LocalDataLockedException extends LocalWriteFailedException {
  LocalDataLockedException() : super();

  @override
  String toString() => 'LocalDataLockedException';
}
