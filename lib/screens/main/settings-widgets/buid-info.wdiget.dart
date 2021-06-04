import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:home_management_app/custom/main-card.dart';
import 'package:package_info/package_info.dart';

class BuildInfoWidget extends StatefulWidget {
  @override
  _BuildInfoWidgetState createState() => _BuildInfoWidgetState();
}

class _BuildInfoWidgetState extends State<BuildInfoWidget> {
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";

  Future _getBuildInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  void initState() {
    super.initState();
    _getBuildInfo();
  }

  @override
  Widget build(BuildContext context) {
    return MainCard(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Expanded(
                    child: Text(
                      "Application Information",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Expanded(
                    child: Text("App name : $appName"),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Expanded(
                    child: Text("Package: $packageName"),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Expanded(
                    child: Text("Version: $version"),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Expanded(
                    child: Text("Build number $buildNumber"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
