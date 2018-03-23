import 'package:flutter/material.dart';

void showAlert(String content, BuildContext context) {
  SnackBar snackBar = new SnackBar(
    content: new Text(content)
  );

  Scaffold.of(context).showSnackBar(snackBar);
}

void log(String logEntry) {
  print('[Info] ' + logEntry);
}

void logWarning(String logEntry) {
  print('[Warning] ' + logEntry);
}

void logError(String logEntry) {
  print('[Error] ' + logEntry);
}