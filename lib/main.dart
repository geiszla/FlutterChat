import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterchat/widgets/app.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);

  runApp(new App());
}
