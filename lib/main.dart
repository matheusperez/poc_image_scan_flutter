import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(color: ThemeData.dark().canvasColor),
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: ThemeData.dark().canvasColor),
      ),
      home: Home(),
    );
  }
}
