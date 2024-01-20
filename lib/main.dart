import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:my_app/data_access/database_interactor.dart';
import 'package:my_app/model/ingredient_factory.dart';
import 'package:my_app/model/recipe_factory.dart';
import 'package:my_app/model/settings.dart';
import 'package:my_app/model/settings_factory.dart';
import 'package:my_app/screens/main_screen.dart';
final getIt = GetIt.instance;

void main() {
  var database = DatabaseInteractor();
  getIt.registerSingleton<DatabaseInteractor>(database);
  getIt.registerSingleton<IngredientFactory>(IngredientFactory(database));
  getIt.registerSingleton<RecipeFactory>(RecipeFactory(database));

  var settingsFactory = SettingsFactory(database);
  getIt.registerSingleton<SettingsFactory>(settingsFactory);
  var settings = Settings();
  getIt.registerSingleton<Settings>(settings);

  // TODO - load this better (doesnt work on real phone)
  // settingsFactory.init().then((value) {
  //   settings = settingsFactory.get();
  //   // getIt.registerSingleton<Settings>(settingsFactory.get());
  // });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/main': (context) => const MainScreen(),
      },
      initialRoute: '/main',
      theme: ThemeData(
        // brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        textTheme: const TextTheme(
          bodyText2: TextStyle(
            fontSize: 18,
          )
        )
      ),
    );
  }
}

