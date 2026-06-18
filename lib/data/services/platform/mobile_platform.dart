import 'package:home_management_app/data/services/platform/platform_type.dart';

import 'package:home_management_app/data/services/platform/platform_context.dart';

class MobilePlatform extends PlatformContext {
  @override
  void initialize() {
  }

  @override
  PlatformType getPlatformType() {
    return PlatformType.Mobile;
  }

  @override
  Future saveFile(String filename, String extension, String value) {
    // TODO: implement save
    throw UnimplementedError();
  }

  @override
  bool isDownloadEnabled() => false;

  @override
  bool isUploadEnabled() => false;
}