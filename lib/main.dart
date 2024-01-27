import 'package:flutter/material.dart';
import 'package:image_generator/material/colors.dart';
import 'package:image_generator/screens/image_generate_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Image Generator',
      theme: ThemeData(
          scaffoldBackgroundColor: bgColor,
          appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              foregroundColor: whiteColor)),
      home: HomeScreen(),
    );
  }
}
