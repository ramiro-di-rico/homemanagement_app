import 'package:home_management_app/data/services/platform/platform_context.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';

/// A platform that reports whatever [type] a test needs. Every other member is unimplemented.
class FakePlatform implements PlatformContext {
  final PlatformType type;

  FakePlatform(this.type);

  @override
  PlatformType getPlatformType() => type;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
