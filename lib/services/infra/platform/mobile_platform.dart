import 'package:home_management_app/services/infra/platform/platform_type.dart';

import 'platform_context.dart';

class MobilePlatform extends PlatformContext {
  @override
  void initialize() {
  }

  @override
  PlatformType getPlatformType() {
    return PlatformType.Mobile;
  }
}