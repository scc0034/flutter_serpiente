import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

/*
 * https://pub.dev/packages/carousel_slider#-example-tab-
 */
final List<String> imgList = [
  'assets/img/carousel/python.jpg',
  'assets/img/carousel/angularjs.jpg',
  'assets/img/carousel/flutter.png',
  'assets/img/carousel/firebase.png',
  'assets/img/carousel/java.jpg',
  'assets/img/carousel/bootstrap.png',
  'assets/img/carousel/html.jpg',
  'assets/img/carousel/javascript.jpg',
  'assets/img/carousel/git.png',
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
    ));
  }

  final List<Widget> imageSliders = imgList
      .map((item) => Container(
            child: Container(
              margin: EdgeInsets.all(5.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Stack(
                    children: <Widget>[
                      Image.asset(item, fit: BoxFit.fitHeight),
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
                          /*padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),*/
                          /*child: Text(
                            'No. ${imgList.indexOf(item)} image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),*/
                        ),
                      ),
                    ],
                  )),
            ),
          ))
      .toList();
}
