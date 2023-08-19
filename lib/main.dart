import 'package:flutter/material.dart';
import 'package:pantrysmart/Presentation/Routes/generatedRoutes.dart';
import 'colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.light(
      primary: Color(0xFF84C0C6),
      primaryContainer: Color(0xFF5E9AA0),
      secondary: Color(0xFFE89F71),
      secondaryContainer: Color(0xFFD17B49),
      surface: Colors.white,
      background: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onBackground: Colors.black,
    );

    return MaterialApp(
      title: 'Pantry Smart',
      theme: ThemeData.from(
      colorScheme: colorScheme,
      ),
      //home: const MyHomePage(),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator().generateRoute,
    );
  }
}
