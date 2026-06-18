import 'package:flutter/foundation.dart';

import 'app_platform_resolver.dart';
import 'package:home_management_app/data/services/platform/platform_context.dart';
import 'web_platform_resolver.dart';

class PlatformStrategy{

  static PlatformContext createPlatform() {

    if(kIsWeb){
      return WebPlatformResolver().getWebPlatform();
    }

    return AppPlatformResolver.createPlatform();
  }
}



