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
  _AdBannerState createState() => _AdBannerState(ads : this.ads);
}

class _AdBannerState extends State<AdBanner> {
  bool ads = false;
  int _coins = 0;

  _AdBannerState({this.ads});
  @override
  void initState() {
    if(ads){
      AdMobService.showBannerAd();
      //AdMobService.showInterstitialAd();
    }else{
      AdMobService.hideBannerAd();
      //AdMobService.hideInterstitialAd();
    }   
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Center(
        child: Column(
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
            /*RaisedButton(
                child: const Text('SHOW BANNER'),
                onPressed: () {
                  _bannerAd ??= createBannerAd();
                  _bannerAd
                    ..load()
                    ..show(
                      anchorOffset: 60.0,
                      // Positions the banner ad 10 pixels from the center of the screen to the right
                      horizontalCenterOffset: 10.0,
                      // Banner Position
                      anchorType: AnchorType.bottom,
                    );
                }),
            RaisedButton(
                child: const Text('SHOW BANNER WITH OFFSET'),
                onPressed: () {
                  _bannerAd ??= createBannerAd();
                  _bannerAd
                    ..load()
                    ..show(horizontalCenterOffset: -50, anchorOffset: 100);
                }),
            RaisedButton(
                child: const Text('REMOVE BANNER'),
                onPressed: () {
                  _bannerAd?.dispose();
                  _bannerAd = null;
                }),
            RaisedButton(
              child: const Text('SHOW REWARDED VIDEO'),
              onPressed: () {
                RewardedVideoAd.instance.show();
              },
            ),
            Text("You have $_coins coins."),
          ].map((Widget button) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: button,
            );
          }).toList(),*/
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
