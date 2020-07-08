import 'package:flutter/material.dart';
import 'package:flutter_snake/src/pages/games/fourInARow/invitar_page.dart';
import 'package:flutter_snake/src/pages/games/fourInARow/unir_page.dart';
import 'package:flutter_snake/src/services/admob_service.dart';
import 'package:flutter_snake/src/widget/go_back.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';

// ignore: must_be_immutable
class FourRowPage extends StatefulWidget {
  bool ads = false;
  FourRowPage({this.ads});

  @override
  _FourRowPageState createState() => _FourRowPageState(ads:ads);
}

class _FourRowPageState extends State<FourRowPage> with TickerProviderStateMixin {

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

  AnimationController _controller;

  @override
  void initState() {
    ads ?AdMobService.showBannerAd() : AdMobService.hideBannerAd();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();  
    super.dispose();
  }
  
  void onAfterBuild(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: MenuLateral(),
      appBar: AppBar(
        title: Text("Cuatro en raya Online"),
        automaticallyImplyLeading: true,
          leading: GoBack.volverAtras(context),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(

                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: Colors.yellow[100],
                  elevation: 10,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset("assets/img/fichayellow.png"),
                        Divider(),

                        Text("Invite a friend")
                      ],
                    ),
                  ),
                onTap: () async {
                    await new Future.delayed(const Duration(milliseconds: 500));
                    Navigator.push(context, new MaterialPageRoute(builder: (__) => new InvitarPage(ads:false)));

                },
              ),
            ],
          ),
          SizedBox(height: 40,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: Colors.red[100],
                  elevation: 10,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset("assets/img/fichared.png"),
                        Divider(),
                        Text("Join game"),
                      ],
                    ),
                  ),
                onTap: () async{
                   
                    await new Future.delayed(const Duration(milliseconds: 500));
                    Navigator.push(context, new MaterialPageRoute(builder: (__) => new UnirPage(ads:false)));
                  
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