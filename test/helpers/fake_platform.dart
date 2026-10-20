import 'package:home_management_app/data/services/platform/platform_context.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';

/// A platform that reports whatever [type] a test needs, and whether files can be
/// downloaded and uploaded. Every other member is unimplemented.
class FakePlatform implements PlatformContext {
  final PlatformType type;
  final bool canDownload;
  final bool canUpload;

  FakePlatform(this.type, {this.canDownload = false, this.canUpload = false});

  @override
  PlatformType getPlatformType() => type;

  @override
  bool isDownloadEnabled() => canDownload;

  @override
  bool isUploadEnabled() => canUpload;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
