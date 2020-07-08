import 'package:flutter/material.dart';
import 'package:flutter_snake/src/services/admob_service.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';

// ignore: must_be_immutable
class GamesPage extends StatefulWidget {

  bool ads = false;
  GamesPage({this.ads});
  
  @override
  _GamesPageState createState() => _GamesPageState(ads:ads);
}

class _GamesPageState extends State<GamesPage> {
  bool ads = false;
  _GamesPageState({this.ads});

  @override
  void initState() {
    if(ads){
      AdMobService.showBannerAd();
    }else{
      AdMobService.hideBannerAd();
    }
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuLateral(),
      appBar: AppBar(
        title: Text("About Page"),
      ),
      // Contenido de la parte de about
      body: ListView(
      children: <Widget>[
        Divider(),
        ListTile(
          leading: ClipRect(
            child: Image.asset("assets/img/snakeblue.png"),
          ),
          trailing: Icon(Icons.arrow_right),
          title : Text("Snake"),
          onTap: () => Navigator.pushNamed(context, "snake"),
        ),
        Divider(),
        ListTile(
          leading: ClipRect(
            child: Image.asset("assets/img/fourgame.png"),
          ),
          trailing: Icon(Icons.arrow_right),
          title : Text("Four in a row"),
          onTap: () => Navigator.pushNamed(context, "four"),
        ),
        Divider(),
      ],
    ));
  }
}