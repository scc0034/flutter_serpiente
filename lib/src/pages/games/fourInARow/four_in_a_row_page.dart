import 'package:flutter/material.dart';
import 'package:flutter_snake/src/services/admob_service.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';

// ignore: must_be_immutable
class FourRowPage extends StatefulWidget {
  bool ads = false;
  FourRowPage({this.ads});

  @override
  _FourRowPageState createState() => _FourRowPageState(ads:ads);
}

class _FourRowPageState extends State<FourRowPage> {

  ///Publicidad
  bool ads = false;
  _FourRowPageState({this.ads});

  /// Para controlar la animacion del contenedor
  double _altoContainer = 100;
  double _anchoContainer = 100;
  Color _colorContainer1 = Colors.yellow[100];
  Color _colorContainer2 = Colors.red[100];
  BorderRadiusGeometry _borderRadiuscontainer = BorderRadius.circular(1);

  @override
  void initState() {
    ads ?AdMobService.showBannerAd() : AdMobService.hideBannerAd();
    _animateContaienrs();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {

    AnimationController _controller;

    return Scaffold(
      drawer: MenuLateral(),
      appBar: AppBar(
        title: Text("Cuatro en raya Online"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            child: AnimatedContainer(
              child: Text("Invitar a un amigo"),
              width: _anchoContainer,
              height: _altoContainer,
              decoration: BoxDecoration(
                color: _colorContainer1,
                borderRadius: _borderRadiuscontainer,
                border: Border.all(color: Colors.black),
              ),
              duration: Duration(seconds: 2),
              curve: Curves.easeInOutQuad,
            ),
            onTap: (){
              print("Tocado invitar amigo");
            },
          ),
          GestureDetector(
            child: AnimatedContainer(
              child: Text("Unirme a partida"),
              width: _anchoContainer,
              height: _altoContainer,
              decoration: BoxDecoration(
                color: _colorContainer1,
                borderRadius: _borderRadiuscontainer,
                border: Border.all(color: Colors.black),
              ),
              duration: Duration(seconds: 2),
              curve: Curves.easeInOutQuad,
            ),
            onTap: (){
              print("Tocado recibir codigo de amigo");
            },
          ),
        ],
      ),
    );
  }


  void _animateContaienrs(){
    setState(() {
      _anchoContainer = 300;
      _altoContainer = 300;
      _colorContainer1 = Colors.yellow[400];
      _colorContainer1 = Colors.red[400];
      _borderRadiuscontainer = BorderRadius.circular(5);
    });  
  }
}