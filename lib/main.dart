import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/app.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);

  runApp(new App());
}
