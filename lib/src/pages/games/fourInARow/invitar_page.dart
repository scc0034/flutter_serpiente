import 'package:flutter/material.dart';
import 'package:flutter_snake/src/services/sing_in_service.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';



class InvitarPage extends StatefulWidget {

  bool ads = false;
  InvitarPage({this.ads});
  
  @override
  _InvitarPageState createState() => _InvitarPageState(ads : ads);
}

class _InvitarPageState extends State<InvitarPage> {

  ///Publicidad
  bool ads = false;
  _InvitarPageState({this.ads});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Invitar amigo"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        
        children: <Widget>[
          Text("Codigo INVITACION : 12345689"),
          SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                minRadius: 50,
                backgroundColor: Colors.blue,
                backgroundImage: NetworkImage(imageUrlGoogle,),
              ),
              SizedBox(width: 50,),
              GestureDetector(
                child: CircleAvatar(
                  minRadius: 50,
                  backgroundColor: Colors.blue,
                  child: Image.asset("assets/img/whatsapp.png"),
                ),
                onTap: (){
                  FlutterShareMe()
                       .shareToWhatsApp(base64Image: null, msg: "161616161616");
                },
              )
            ],
          ),
        ],
      ),
      
    );
  }
}