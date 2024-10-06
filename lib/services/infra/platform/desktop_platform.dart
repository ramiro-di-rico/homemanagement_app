import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'platform_context.dart';
import 'platform_type.dart';

class DesktopPlatform extends PlatformContext {
  @override
  void initialize() {
  }

  @override
  PlatformType getPlatformType() {
    return PlatformType.Desktop;
  }

  @override
  Future saveFile(String filename, String extension, String value) async {
    var downloadPath = await getDownloadsDirectory();
    final path = await downloadPath!.path;
    var filenameWithoutSpaces = filename.replaceAll(' ', '_');

    if (await Directory(path).exists() == false) {
      Directory(path).createSync();
    }

    final file = File('$path/$filenameWithoutSpaces.$extension');

    return file.writeAsString(value);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  bool isDownloadEnabled() => false;

  @override
  bool isUploadEnabled() => true;
}