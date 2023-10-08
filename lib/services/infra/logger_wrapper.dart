import 'package:logger/logger.dart';

import 'file_logger_output.dart';

class LoggerWrapper {
  Logger _logger = Logger(
    filter: null,
    printer: SimplePrinter(),
    output: FileLoggerOutput(),
  );

  void i(String message){
    _logger.i(message);
  }

  void e(dynamic message){
    _logger.e(message);
  }
}