import 'dart:convert';
import 'dart:html' as html;

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

  @override
  Future saveFile(String filename, String extension, String value) async {

    // prepare
    final bytes = utf8.encode(value);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = "$filename.$extension";
    html.document.body?.children.add(anchor);

    // download
    anchor.click();

    // cleanup
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}