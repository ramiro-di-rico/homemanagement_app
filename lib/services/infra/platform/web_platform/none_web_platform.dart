import 'package:flutter/widgets.dart';

import '../platform_context.dart';
import '../platform_type.dart';
import 'base_web_platform.dart';

class WebPlatform extends BaseWebPlatformContext{
  PlatformContext createWebPlatform() {
    return NoneWebPlatformImpl();
  }
}

class NoneWebPlatformImpl implements PlatformContext {

  @override
  BuildContext? context;

  @override
  PlatformType getPlatformType() {
    // TODO: implement getPlatformType
    throw UnimplementedError();
  }

  @override
  void initialize() {
    // TODO: implement initialize
  }

  @override
  Future saveFile(String filename, String extension, String value) {
    // TODO: implement saveFile
    throw UnimplementedError();
  }

  @override
  void setContext(BuildContext buildingContext) {
    // TODO: implement setContext
  }

  @override
  bool isDownloadEnabled() => false;

  @override
  bool isUploadEnabled() {
    // TODO: implement isUploadEnabled
    throw UnimplementedError();
  }
}