import 'package:easy_finance/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peliculas App',
      debugShowCheckedModeBanner: false,
      initialRoute: 'home_page',
      routes: {'home_page': (BuildContext context) => HomePage()},
      theme: ThemeData.light().copyWith(
        appBarTheme: AppBarTheme(color: Colors.teal),
      ),
    );
  }
}
