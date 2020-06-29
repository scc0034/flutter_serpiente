import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'dart:io';
import 'package:flutter_snake/src/services/admob_service.dart';

// VARIABLES DE CONTROL DE LOS ANUNCIOS
//const String testDevice = 'YOUR_DEVICE_ID';
// ID del anuncio banner creado en admob
final _admobService = AdMobService();
final _appid = _admobService.getAdMobAppId();

/**
 * https://medium.com/@sravanyakatta6/showing-ads-in-flutter-app-f9f1b72eec51
 * https://www.youtube.com/watch?v=rXYmbTBT3Yo
 * https://pub.dev/packages/admob_flutter#-readme-tab-
 */
class AdBanner extends StatefulWidget {
  @override
  _AdBannerState createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: <String>[] ,
    keywords: <String>['games', 'code','flutter'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );

  BannerAd _bannerAd;
  int _coins = 0;

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: _admobService.getBannerHome(),
      size: AdSize.smartBanner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }


  @override
  void initState() {
    print("Lo que tenemos dentro del appID = $_appid");
    super.initState();
    FirebaseAdMob.instance.initialize(appId: _appid);
    _bannerAd = createBannerAd()..load()..show(
      anchorOffset: 60.0,
      // Positions the banner ad 10 pixels from the center of the screen to the right
      horizontalCenterOffset: 10.0,
      // Banner Position
      anchorType: AnchorType.bottom,
    );

    print("Dentro del initState");
    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      print("RewardedVideoAd event $event");
      if (event == RewardedVideoAdEvent.rewarded) {
        setState(() {
          _coins += rewardAmount;
        });
      }
    };
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RaisedButton(
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
                }
            ),
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
          }).toList(),
        ),
      ),
    );
  }
}