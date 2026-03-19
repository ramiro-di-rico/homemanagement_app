import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

import 'package:flutter/widgets.dart';
import 'package:home_management_app/services/infra/platform/platform_type.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import '../platform_context.dart';
import 'base_web_platform.dart';

class WebPlatform extends BaseWebPlatformContext{
  PlatformContext createWebPlatform() {
    return WebPlatformImpl();
  }
}

class WebPlatformImpl extends PlatformContext {
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

  @override
  Future saveFile(String filename, String extension, String value) async {

    // prepare
    final bytes = utf8.encode(value);
    final blob = web.Blob([bytes.toJS].toJS);
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = "$filename.$extension";
    web.document.body?.appendChild(anchor);

    // download
    anchor.click();

    // cleanup
    web.document.body?.removeChild(anchor);
    web.URL.revokeObjectURL(url);
  }

  @override
  bool isDownloadEnabled() => true;

  @override
  bool isUploadEnabled() => true;
}