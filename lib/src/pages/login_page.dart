import 'package:flutter/material.dart';
import 'package:flutter_snake/src/pages/home_page.dart';
import 'package:flutter_snake/src/services/admob_service.dart';
import 'package:flutter_snake/src/services/sing_in_service.dart';
import 'package:flutter_snake/src/utils/delayed_animation.dart';

/*
 * Clase que se encarga del login de los usuarios con gmail
 */
// ignore: must_be_immutable
class LoginPage extends StatefulWidget {
  bool ads = false;
  LoginPage({this.ads});
  @override
  _LoginPageState createState() => _LoginPageState(ads : ads);
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // Atributos de la clase para controlar la animación
  final int delayedAmount = 500;
  //double _scale;
  AnimationController _controller;
  bool ads = false;
  _LoginPageState({this.ads});

  @override
  void initState() {
    if(ads){
      AdMobService.showBannerAd();
    }else{
      AdMobService.hideBannerAd();
    }
    // Controlador de la animación de los elementos
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
                /*child: FlutterLogo(
                  size: 150.0,
                ),*/
                child: CircleAvatar(
                  maxRadius: 75,
                  child: Image.asset("assets/img/logoapp.jpg"),
                ),
              ),
              SizedBox(height: 50),
              DelayedAnimation(
                child: Text(
                  "Flutter games",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35.0),
                ),
                delay: delayedAmount + 1000,
              ),
              SizedBox(height: 50),
              DelayedAnimation(
                child: Text(
                  "Samuel Casal Cantero",
                  style: TextStyle(fontSize: 18.0),
                ),
                delay: delayedAmount + 1000,
              ),
              SizedBox(height: 15),
              DelayedAnimation(
                child: Text(
                  "Universidad de Burgos",
                  style: TextStyle(fontFamily: "Roboto", fontSize: 18.0),
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

  ///Método qe nos devuelve el botón de login a la página
  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        _controller.reverse();
        signInWithGoogle().whenComplete(() {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return HomePage(ads: true,);
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
            Image(
                image: AssetImage("assets/img/google_logo.png"), height: 28.0),
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
