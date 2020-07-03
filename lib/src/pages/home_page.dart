import 'package:flutter/material.dart';
import 'package:flutter_snake/src/widget/ad_banner.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {

  bool ads = false;
  HomePage({this.ads}){
    if(this.ads == null){
      this.ads = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: MenuLateral(),
        appBar: AppBar(
          title: Text("Home Page"),
        ),
        body: Scaffold(
          body: AdBanner(ads: this.ads),
        ));
  }
}
