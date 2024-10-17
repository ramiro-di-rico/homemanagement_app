import 'package:flutter/material.dart';

import '../../services/infra/logging_file.dart';

class LoggingView extends StatefulWidget {
  static const String id = '/logging_screen';

  const LoggingView({super.key});

  @override
  State<LoggingView> createState() => _LoggingViewState();
}

class _LoggingViewState extends State<LoggingView> {
  LoggingFile _loggingFile = LoggingFile();
  List<String> logFileContents = [];

  @override
  void initState() {
    super.initState();
    _loggingFile.readLogFile().then((value) {
      setState(() {
        logFileContents = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Logging View'),
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
          ),
        body: SafeArea(
            child: ListView.builder(
                itemCount: logFileContents.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(logFileContents[index]),
                  );
                },)));
  }
}
