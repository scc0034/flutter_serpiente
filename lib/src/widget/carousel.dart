import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

/**
 * https://pub.dev/packages/carousel_slider#-example-tab-
 */
final List<String> imgList = [
  'https://live.mrf.io/statics/i/ps/www.muycomputer.com/wp-content/uploads/2017/07/lenguaje-de-programaci%C3%B3n-1.jpg?width=1200&enable=upscale',
  'https://licencias.info/wp-content/uploads/2019/07/angularjs.jpg',
  'https://cambiodigital-ol.com/wp-content/uploads/2018/11/Logo_Java.jpg',
  'https://cdn.yazilimkitabi.com/Content/image/flutter.png',
  'https://www.koskila.net/wp-content/uploads/2019/01/logo-microsoft-sql-server-595x3350.jpg',
  'https://i.blogs.es/a49483/logo-mongodb-tagline-2/1366_2000.png',
  'https://miro.medium.com/max/1200/1*Vr5hW7ykUC3l1V1yHa6Rfw.png'
];

class Carousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: CarouselSlider(
          options: CarouselOptions(

            aspectRatio: 2.0,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            initialPage: 2,
            autoPlay: true,
          ),
          items: imageSliders,
        )
      );
  }

  final List<Widget> imageSliders = imgList.map((item) => Container(
    child: Container(
      margin: EdgeInsets.all(5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: Stack(
          children: <Widget>[
            Image.network(item, fit: BoxFit.cover, width: 1000.0),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(200, 0, 0, 0),
                      Color.fromARGB(0, 0, 0, 0)
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  'No. ${imgList.indexOf(item)} image',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        )
      ),
    ),
  )).toList();
}