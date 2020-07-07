import 'package:flutter/material.dart';
import 'package:flutter_snake/src/pages/games/fourInARow/invitar_page.dart';
import 'package:flutter_snake/src/pages/games/fourInARow/unir_page.dart';
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
  double _altoContainer1 = 200;
  double _anchoContainer1 = 200;
  double _altoContainer2 = 200;
  double _anchoContainer2 = 200;
  Color _colorContainer1 = Colors.yellow[100];
  Color _colorContainer2 = Colors.red[100];
  BorderRadiusGeometry _borderRadiuscontainer = BorderRadius.circular(1);
  bool _bandera = null;

  @override
  void initState() {
    ads ?AdMobService.showBannerAd() : AdMobService.hideBannerAd();
    //_animateContaienrs(75);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: MenuLateral(),
      appBar: AppBar(
        title: Text("Cuatro en raya Online"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                child: AnimatedContainer(
                  child: Center(child: Text("Invitar a un amigo")),
                  width: _anchoContainer1,
                  height: _altoContainer1,
                  decoration: BoxDecoration(
                    color: _colorContainer1,
                    borderRadius: _borderRadiuscontainer,
                    border: Border.all(color: Colors.black),
                  ),
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOutQuad,
                ),
                onTap: () async {
                  if (_bandera == null){
                    _animateContaienrs(75,true);
                    await new Future.delayed(const Duration(milliseconds: 500));
                    Navigator.push(context, new MaterialPageRoute(builder: (__) => new InvitarPage(ads:false)));
                    _animateContaienrs(-75,true);
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 40,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                child: AnimatedContainer(
                  child: Center(child: Text("Unirme a partida")),
                  width: _anchoContainer2,
                  height: _altoContainer2,
                  decoration: BoxDecoration(
                    color: _colorContainer2,
                    borderRadius: _borderRadiuscontainer,
                    border: Border.all(color: Colors.black),
                  ),
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOutQuad,
                ),
                onTap: () async{
                  if (_bandera == null){
                    _animateContaienrs(75,false);
                    await new Future.delayed(const Duration(milliseconds: 500));
                    Navigator.push(context, new MaterialPageRoute(builder: (__) => new UnirPage(ads:false)));
                    _animateContaienrs(-75,false);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _animateContaienrs(int increment, bool nCont){
    setState(() {
      if (nCont){
        _anchoContainer1 = (200+increment).toDouble();
        _altoContainer1 = (200+increment).toDouble();
        _colorContainer1 = Colors.yellow[400];
        _borderRadiuscontainer = BorderRadius.circular(8);
      }else{
        _anchoContainer2 = (200+increment).toDouble();
        _altoContainer2 = (200+increment).toDouble();
        _colorContainer2 = Colors.red[400];
        _borderRadiuscontainer = BorderRadius.circular(8);
      }
    });  
  }
}