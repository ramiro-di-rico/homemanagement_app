import 'package:flutter/foundation.dart';

import 'app_platform_resolver.dart';
import 'platform_context.dart';
import 'web_platform_resolver.dart';

class PlatformStrategy{

  static PlatformContext createPlatform() {

    if(kIsWeb){
      return WebPlatformResolver().getWebPlatform();
    }

    return AppPlatformResolver.createPlatform();
  }
}



