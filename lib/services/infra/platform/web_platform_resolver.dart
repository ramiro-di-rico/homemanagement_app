import 'package:home_management_app/services/infra/platform/platform_context.dart';

import 'web_platform/stub_web_platform.dart'
  if (dart.library.js_util) 'web_platform/web_platform.dart'
  if (dart.library.io) 'web_platform/none_web_platform.dart';

class WebPlatformResolver {
  WebPlatform? _webPlatform;

  WebPlatformResolver(){
    _webPlatform = WebPlatform();
  }

  PlatformContext getWebPlatform(){
    return _webPlatform!.createWebPlatform();
  }
}