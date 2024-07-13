import 'package:flutter/widgets.dart';
import 'package:home_management_app/services/infra/platform/platform_type.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'platform_context.dart';

class WebPlatform extends PlatformContext {
  @override
  void initialize() {
    usePathUrlStrategy();
  }

  @override
  PlatformType getPlatformType() {

    if (context == null) {
      return PlatformType.Web;
    }

    var screenSize = MediaQuery.of(context!).size;
    var isDesktop = screenSize.width > 720;

    return isDesktop ? PlatformType.Web : PlatformType.WebMobile;
  }
}