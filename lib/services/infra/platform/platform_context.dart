import 'package:home_management_app/services/infra/platform/platform_type.dart';

abstract class PlatformContext{

  void initialize();

  PlatformType getPlatformType();
}