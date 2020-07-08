import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake/src/services/admob_service.dart';
import 'package:flutter_snake/src/services/sing_in_service.dart';
import 'package:flutter_snake/src/widget/go_back.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';

// ignore: must_be_immutable
class RankPage extends StatefulWidget {
  bool ads = false;
  RankPage({this.ads});

  @override
  _RankPageState createState() => _RankPageState(ads : this.ads);
}

/*
 * Clase para controlar los datos que se meten en la colección de la base de datos
 * de Ranking, el packete que uso es : 
 * https://pub.dev/packages/cloud_firestore
 * Video que he seguigo para saber como hacerlo:
 * https://www.youtube.com/watch?v=osp1WL7W9Wo
 * */
class _RankPageState extends State<RankPage> {

  bool ads = false;

  _RankPageState({this.ads});

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
          automaticallyImplyLeading: true,
          leading: GoBack.volverAtras(context),
          title: Text("Ranking Snake"),
        ),
        body: Container(
          // Crea el Widget según llega el contenido
          child: StreamBuilder(
            /**
             * Stremea los datos de la base de datos
             */
            stream: Firestore.instance
                .collection('ranking')
                .orderBy('puntos', descending: true)
                .snapshots(),
            /**
             * QuerySnapshot es lo que devuelve firestore
             */
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              // En el caso de que no tengamos datos mostramos la barra de progreso
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              List<DocumentSnapshot> docs = snapshot.data.documents;
              return ListView.separated(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data = docs[index].data;
                  return Container(
                    decoration: new BoxDecoration(
                      color: _miScore(data['imageUrl'].toString()),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        backgroundImage:
                            NetworkImage(data['imageUrl'].toString()),
                      ),
                      title: Text(data['nombre'].toString()),
                      subtitle: Text("Puntos: ${data['puntos'].toString()}"),
                      trailing: AnimatedContainer(
                        child: _img(index),
                        height: 100,
                        width: 100,
                        duration: Duration(seconds: 1),
                        curve: Curves.fastOutSlowIn,
                        onEnd: () {},
                      ),
                      onTap: () {
                        Text('Another data');
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
              );
            },
          ),
        ));
  }

  ///Devuelve el color amarillo para el jugador de la partida
  Color _miScore(String img) {
    if (img.compareTo(imageUrlGoogle) == 0) {
      return new Color.fromARGB(200, 255, 224, 51);
    }
    return new Color.fromARGB(0, 255, 224, 51);
  }

  /// Coloca una de las medallas, según la posición relativa a la puntuación
  Image _img(int index) {
    if (index < 3) {
      return Image.asset("assets/img/medal${index + 1}.png");
    } else {
      return Image.asset("assets/img/TRANSPA.gif");
    }
  }
}
