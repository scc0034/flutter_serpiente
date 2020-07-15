import 'dart:io';
import 'package:firebase_admob/firebase_admob.dart';

/*
 * Clase que cotrola los id que se usan en la aplicación en la parte de adservice
 */
class AdMobService {
  AdMobService();
  static BannerAd _bannerAd;
  static BannerAd _bannerAdOficial;
  static InterstitialAd _interstitialAd;

  /// Método para inicializar la instancia con admob
  static Future  initialize() async{
    FirebaseAdMob.instance.initialize(appId: "ca-app-pub-7462396340145780~9170330392");
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
      const String unitId = "ca-app-pub-7462396340145780/9142410233";
      return unitId;
    }
    return null;
  }

  ///Devuelve el id del banner de ads
  static String getIdInterstitial() {
    if (Platform.isAndroid) {
      const String unitId = "ca-app-pub-7462396340145780/2167321238";
      return unitId;
    }
    return null;
  }

  static InterstitialAd _createInterstitialAd(String adId) {
    return InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event is $event");
      },
    );
  }

  /// Método que devuelve un bannerAd
  static Future<BannerAd> _createBannerAd(String adId) async{
    await initialize();
    return BannerAd(
      adUnitId: adId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }


  /// Método que carga el banner
  static void showBannerAd() async{
    if (_bannerAd == null) _bannerAd = await _createBannerAd(BannerAd.testAdUnitId.toString());
    _bannerAd
      ..load()
      ..show(anchorOffset: 0.0, anchorType: AnchorType.bottom);
  }

  /// Método que deseacitva el banner, dejandolo a null
  static void hideBannerAd() async {
    await _bannerAd.dispose();
    _bannerAd = null;
  }

    /// Método que carga el banner
  static void showBannerAdOficial()async {
    
    if (_bannerAdOficial == null) _bannerAdOficial = await _createBannerAd(getIdBanner());
    _bannerAdOficial
      ..load()
      ..show(anchorOffset: 0.0, anchorType: AnchorType.bottom);
  }

  /// Método que deseacitva el banner, dejandolo a null
  static void hideBannerAdOficial() async {
    await _bannerAdOficial.dispose();
    _bannerAdOficial = null;
  }

  /// Método que carga el banner
  static void showInterstitialAd() {
    if (_interstitialAd == null)
      _interstitialAd = _createInterstitialAd(getIdInterstitial());
    _interstitialAd
      ..load()
      ..show(
        anchorType: AnchorType.bottom,
        anchorOffset: 0.0,
        horizontalCenterOffset: 0.0,
      );
  }

  /// Método que deseacitva el banner, dejandolo a null
  static void hideInterstitialAd() async {
    await _interstitialAd.dispose();
    _interstitialAd = null;
  }

  /// Método que devuelve la información del target para usar en los videos fuera de la clase
  static MobileAdTargetingInfo getMobileTargetInfo() {
    return targetingInfo;
  }
}
