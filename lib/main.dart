import 'package:chat_sg/choose_your_path.dart';
import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';

void main() async {
  runApp(const MyApp());
  setWindowSize();
}

Future<void> setWindowSize() async {
  await DesktopWindow.setMinWindowSize(const Size(1024, 720));
  await DesktopWindow.setWindowSize(const Size(1024, 720));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ChooseYourPath(),
    );
  }
}
