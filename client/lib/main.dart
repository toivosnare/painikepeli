import 'package:flutter/material.dart';
import 'package:client/home_page.dart';

// App entry point
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final title = 'Painikepeli';
    return MaterialApp(
      title: title,
      home: HomePage(title: title),
    );
  }
}
