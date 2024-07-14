import 'package:home_management_app/services/infra/platform/platform_type.dart';

import 'platform_context.dart';

class DesktopPlatform extends PlatformContext {
  @override
  void initialize() {
  }

  @override
  PlatformType getPlatformType() {
    return PlatformType.Desktop;
  }

  @override
  Future saveFile(String filename, String extension, String value) {
    // TODO: implement save
    throw UnimplementedError();
  }
}