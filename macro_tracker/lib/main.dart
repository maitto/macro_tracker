import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:macro_tracker/view_models/home_page_view_model.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'views/home_page_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomePageViewModel()..init()),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('fi', ''), // FI
          // Add other supported locales here
        ],
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue, brightness: Brightness.light,),
          useMaterial3: true,
          textTheme: TextTheme(
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorScheme.fromSeed(
                      seedColor: Colors.blue, brightness: Brightness.light,)
                  .primary,
            ),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue, brightness: Brightness.dark,),
          useMaterial3: true,
          textTheme: TextTheme(
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorScheme.fromSeed(
                      seedColor: Colors.blue, brightness: Brightness.light,)
                  .primary,
            ),
          ),
        ),
        themeMode: ThemeMode.system, // Use system theme mode (light/dark)
        home: const HomePage(title: 'Simple Macro Tracker'),
      ),
    );
  }
}
