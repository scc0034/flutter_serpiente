import 'package:flutter/material.dart';
import 'package:flutter_snake/src/models/variables_persistentes.dart';
import 'package:flutter_snake/src/pages/home_page.dart';
import 'package:flutter_snake/src/routes/routes.dart';
import 'package:flutter_snake/src/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_snake/src/utils/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
        builder: (_) => ThemeChanger(ThemeData.light()),
        child: new MaterialAppWithTheme(
        
        ),
    );
  }
}

class MaterialAppWithTheme extends StatefulWidget {
  @override
  _MaterialAppWithThemeState createState() => _MaterialAppWithThemeState();
}

class _MaterialAppWithThemeState extends State<MaterialAppWithTheme> {
  // Servicios de la base de datos
  DatabaseService dbService = DatabaseService.instance;

@override
  void initState() {
    super.initState();
    _loadSettings(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return MaterialApp(
      theme: theme.getTheme(),
      title: "Flutter Snake",
        // Quitamos el banner que aparece de debug en el movil
        debugShowCheckedModeBanner: false,
        /**
         * RUTAS
         */
        initialRoute: '/',
        routes: getAplicationRoutes(),// Cogemos las rutas de routes.dart
        onGenerateRoute: (RouteSettings settings){

          // En caso de que no encuentre la ruta, vuelve al homePage
          return MaterialPageRoute(
            builder: (BuildContext context ) => HomePage(),
          );
        },
    );
  }

   _loadSettings(BuildContext context) async {
    final VariablesPersistentes varColor = await dbService.getVar("selectorColor");
    if(varColor != null){
      Provider.of<ThemeChanger>(context).setTheme(ThemeData.light());
    }
    if(varColor.value == 0){
      Provider.of<ThemeChanger>(context).setTheme(ThemeData.light());
    }else{
      Provider.of<ThemeChanger>(context).setTheme(ThemeData.dark());
    }
  }
}
/*
class MyApp extends StatelessWidget {
  
  /**
   * Tenemos que sobreescribir el método build, que nos retorna un widget
   * con el fin de rellenar la pantalla.
   * Tambien es necesario que para este primer widget se le pase el contesto
   * que no es más que la configuración.
   */
  @override
  Widget build(BuildContext context) {
    
    return ChangeNotifierProvider<ThemeChanger>(
        builder: (_) => ThemeChanger(ThemeData.light()),
        child: new MaterialAppWithTheme(
        
        ),
    );
  }
}

class MaterialAppWithTheme extends StatelessWidget {

  // Servicios de la base de datos
  DatabaseService dbService = DatabaseService.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return MaterialApp(
      theme: theme.getTheme(),
      title: "Flutter Snake",
        // Quitamos el banner que aparece de debug en el movil
        debugShowCheckedModeBanner: false,
        /**
         * RUTAS
         */
        initialRoute: '/',
        routes: getAplicationRoutes(),// Cogemos las rutas de routes.dart
        onGenerateRoute: (RouteSettings settings){

          // En caso de que no encuentre la ruta, vuelve al homePage
          return MaterialPageRoute(
            builder: (BuildContext context ) => HomePage(),
          );
        },
    );
  }

   _loadSettings(BuildContext context) async {
    final VariablesPersistentes varColor = await dbService.getVar("selectorColor");
    if(varColor != null){
      Provider.of<ThemeChanger>(context).setTheme(ThemeData.light());
    }
    if(varColor.value == 0){
      Provider.of<ThemeChanger>(context).setTheme(ThemeData.light());
    }else{
      Provider.of<ThemeChanger>(context).setTheme(ThemeData.dark());
    }
  }
}
*/
