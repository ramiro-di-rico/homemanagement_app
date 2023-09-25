import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:home_management_app/extensions/datehelper.dart';

class LoggingFile{
  
  Future<File> getLatestLoggerFile() async {
    var date = DateTime.now();
    var currentDate = date.getFormattedCurrentDate();

    var filePath = Directory.systemTemp.absolute.uri.toFilePath().toString() + '${currentDate}_log.txt';
    var file = File(filePath);

    if (! await file.exists()){
      await file.create();
    }

    return file;
  }

  Future moveLoggingFileToDownload() async {
    const path = '/storage/emulated/0/Download/';
    final String uuid = Uuid().v1();

    var loggerFile = await getLatestLoggerFile();
    var loggerFileName = loggerFile.path.split('/').last;
    var loggerFileDownloadPath = path + uuid + loggerFileName;
    var loggerFileDownload = File(loggerFileDownloadPath);

    if (await loggerFileDownload.exists()){
      await loggerFileDownload.delete();
    }

    loggerFile.copy(loggerFileDownloadPath);
  }
}