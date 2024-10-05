import 'package:flutter/src/widgets/framework.dart';
import 'package:home_management_app/services/infra/platform/platform_type.dart';

abstract class PlatformContext{
  BuildContext? context;

  void initialize();

  PlatformType getPlatformType();

  void setContext(BuildContext buildingContext) {
    context = buildingContext;
  }

  Future saveFile(String filename, String extension, String value);

  bool isDownloadEnabled();

  bool isUploadEnabled();

  Future<String> pickFile();
}