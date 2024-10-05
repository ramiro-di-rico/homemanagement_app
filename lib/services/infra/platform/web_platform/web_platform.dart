import 'dart:convert';
import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';
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

  @override
  bool isDownloadEnabled() => true;

  @override
  bool isUploadEnabled() => true;

  @override
  Future<String> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      var fileContent = await file.xFile.readAsString();
      return fileContent;
    }

    return '';
  }
}