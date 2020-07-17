import 'package:flutter/material.dart';
import 'package:flutter_snake/src/widget/ad_banner.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  bool ads = false;
  HomePage({this.ads}) {
    if (this.ads == null) {
      this.ads = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: MenuLateral(),
        appBar: AppBar(
          title: Text("Home"),
        ),
        body: Scaffold(
          backgroundColor: Colors.grey,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              
              new Image.asset("assets/img/poster.jpg"),
              AdBanner(ads: this.ads),
            ],
          )
            
           
        ));
  }
}
