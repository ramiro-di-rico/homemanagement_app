import 'dart:io';

import 'package:home_management_app/extensions/datehelper.dart';
import 'package:logger/logger.dart';

class FileLoggerOutput extends LogOutput {

  @override
  void output(OutputEvent event) async {
    var file = await getLoggerFile();

    if (file != null) {
      for (var line in event.lines) {
        await file.writeAsString("${line.toString()}\n",
            mode: FileMode.writeOnlyAppend);
      }
    } else {
      for (var line in event.lines) {
        print(line);
      }
    }
  }

  Future<File> getLoggerFile() async {
    var date = DateTime.now();
    var currentDate = date.getFormattedCurrentDate();

    var filePath = Directory.systemTemp.absolute.uri.toFilePath().toString() + '${currentDate}_log.txt';
    var file = File(filePath);

    if (! await file.exists()){
      await file.create();
    }

    return file;
  }
}