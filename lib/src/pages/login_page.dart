import 'package:flutter/material.dart';
import 'package:flutter_snake/src/pages/home_page.dart';
import 'package:flutter_snake/src/services/sing_in_service.dart';
import 'package:flutter_snake/src/utils/delayed_animation.dart';

/**
 * Clase que se encarga del login de las personas con gmail
 */
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  // Atributos de la clase para controlar la animación
  final int delayedAmount = 500;
  double _scale;
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Material(
                child: FlutterLogo(
                  size: 150.0,
                ),
              ),
              SizedBox(height: 50),
              DelayedAnimation(
                  child: Text(
                    "Flutter_snake",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35.0),
                  ),
                  delay: delayedAmount + 1000,
              ),
              SizedBox(height: 50),
              DelayedAnimation(
                  child: Text(
                    "Samuel Casal Cantero",
                    style: TextStyle(
                        fontSize: 18.0),
                  ),
                  delay: delayedAmount + 1000,
                ),
              SizedBox(height: 15),
              DelayedAnimation(
                  child: Text(
                    "Universidad de Burgos",
                    style: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 18.0),
                  ),
                  delay: delayedAmount + 1000,
                ),
              SizedBox(height: 50),
              DelayedAnimation(
                  child: _signInButton(),
                  delay: delayedAmount + 1000,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        _controller.reverse();
        signInWithGoogle().whenComplete(() {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return HomePage();
              },
            ),
          );
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 28.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}