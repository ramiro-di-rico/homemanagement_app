import 'dart:io';

import 'desktop_platform.dart';
import 'mobile_platform.dart';

class AppPlatformResolver{

  static createPlatform(){

    var isDesktop = Platform.isMacOS || Platform.isWindows || Platform.isLinux;

    return isDesktop ? DesktopPlatform() : MobilePlatform();
  }
}