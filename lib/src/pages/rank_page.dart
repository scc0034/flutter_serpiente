import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';

class RankPage extends StatefulWidget {
  @override
  _RankPageState createState() => _RankPageState();
}
/*
 * Clase para controlar los datos que se meten en la colección de la base de datos
 * de Ranking, el packete que uso es : 
 * https://pub.dev/packages/cloud_firestore
 * Video que he seguigo para saber como hacerlo:
 * https://www.youtube.com/watch?v=osp1WL7W9Wo
 * */
class _RankPageState extends State<RankPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuLateral(),
        appBar: AppBar(
          title : Text("Ranking Page"),
        ),
        body: Container(
          // Crea el Widget según llega el contenido
          child: StreamBuilder(
            /**
             * Stremea los datos de la base de datos
             */
            stream: Firestore.instance.collection('ranking').orderBy('puntos',descending: true).snapshots(),
            /**
             * QuerySnapshot es lo que devuelve firestore
             */
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
              // En el caso de que no tengamos datos mostramos la barra de progreso
              if(!snapshot.hasData){
                return Center(child: CircularProgressIndicator(),);
              }
              List<DocumentSnapshot> docs = snapshot.data.documents;
              return ListView.separated(
                itemCount: docs.length,
                itemBuilder: (context, index){
                  Map<String,dynamic> data = docs[index].data;
                  return ListTile(
                    leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    backgroundImage: NetworkImage(data['imageUrl'].toString()),
                    ),
                    title: Text(data['nombre'].toString()),
                    subtitle: Text("Puntos: ${data['puntos'].toString()}"),
                    //trailing: Icon(Icons.keyboard_arrow_right),
                    
                    onTap: () {
                      Text('Another data');
                    },
                  );
                }, 
                separatorBuilder: (context, index) {
                  return Divider();
                },
              );
            },
          ),
        )
    );
  }
}