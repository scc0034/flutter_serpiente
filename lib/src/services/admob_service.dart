import 'dart:io';
import 'package:firebase_admob/firebase_admob.dart';

/*
 * Clase que cotrola los id que se usan en la aplicación en la parte de adservice
 */
class AdMobService {

  AdMobService();
  static BannerAd _bannerAd; 
  static InterstitialAd _interstitialAd;

  /// Método para inicializar la instancia con admob
  static void initialize() {
    FirebaseAdMob.instance.initialize(appId: getAdMobAppId());
  }

  /// Datos del target
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    //testDevices: testDevice != null ? <String>[testDevice] : null,
    testDevices: <String>[],
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );


  /// DEvuelve el id de la aplicación en firebase
  static String getAdMobAppId() {
    if (Platform.isAndroid) {
      const String appId = "ca-app-pub-7462396340145780~9170330392";
      return appId;
    }
    return null;
  }

  ///Devuelve el id del banner de ads
  static String getIdBanner() {
    if (Platform.isAndroid) {
      const String appId = "ca-app-pub-7462396340145780/9142410233";
      return appId;
    }
    return null;
  }

  /// Devuelve el id del intersticial (iFrame de html), algo parecido
  /*String getIntersticialAd() {
    if (Platform.isAndroid) {
      const String appId = "ca-app-pub-7462396340145780/8871642021";
      return appId;
    }
    return null;
  }*/
  
  /// Método que devuelve un bannerAd
  static BannerAd _createBannerAd(String adId) {
    return BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  /// Método que carga el banner
  static void showBannerAd() {
    if (_bannerAd == null) _bannerAd = _createBannerAd(getIdBanner());
    _bannerAd
      ..load()
      ..show(anchorOffset: 0.0, anchorType: AnchorType.bottom);
  }

  /// Método que deseacitva el banner, dejandolo a null
  static void hideBannerAd() async {
    await _bannerAd.dispose();
    _bannerAd = null;
  }
}
