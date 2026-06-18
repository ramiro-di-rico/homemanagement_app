import 'dart:io';
import 'package:logger/logger.dart';
import 'logging_file.dart';

class FileLoggerOutput extends LogOutput {

  @override
  void output(OutputEvent event) async {
    var loggingFile = LoggingFile();
    var file = await loggingFile.getLatestLoggerFile();

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
}