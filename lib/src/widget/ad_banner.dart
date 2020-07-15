import 'package:flutter/material.dart';
import 'package:flutter_snake/src/services/admob_service.dart';

// VARIABLES DE CONTROL DE LOS ANUNCIOS
//const String testDevice = 'YOUR_DEVICE_ID';
// ID del anuncio banner creado en admob

/*
 * https://medium.com/@sravanyakatta6/showing-ads-in-flutter-app-f9f1b72eec51
 * https://www.youtube.com/watch?v=rXYmbTBT3Yo
 * https://pub.dev/packages/admob_flutter#-readme-tab-
 */
// ignore: must_be_immutable
class AdBanner extends StatefulWidget {
  bool ads = false;
  AdBanner({this.ads});

  @override
  _AdBannerState createState() => _AdBannerState(ads: this.ads);
}

class _AdBannerState extends State<AdBanner> {
  bool ads = false;

  _AdBannerState({this.ads});
  @override
  void initState() {
    AdMobService.initialize();
    if (ads) {
      AdMobService.showBannerAdOficial();
      //AdMobService.showInterstitialAd();
    } else {
      AdMobService.hideBannerAdOficial();
      //AdMobService.hideInterstitialAd();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
          /*child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("Dentro del home, debería de mostrarse el banner!"),
            RaisedButton(
                child: const Text('REMOVE BANNER TEST '),
                onPressed: () {
                  AdMobService.hideBannerAd();
                }),
            
          ]

        ),*/
          ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
