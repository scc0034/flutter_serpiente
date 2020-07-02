import 'dart:io';

/*
 * Clase que cotrola los id que se usan en la aplicación en la parte de adservice
 */
class AdMobService {
  AdMobService();

  /// DEvuelve el id de la aplicación en firebase
  String getAdMobAppId() {
    if (Platform.isAndroid) {
      const String appId = "ca-app-pub-7462396340145780~9379634838";
      return appId;
    }
    return null;
  }

  ///Devuelve el id del banner de ads
  String getBannerHome() {
    if (Platform.isAndroid) {
      const String appId = "ca-app-pub-7462396340145780/7300266407";
      return appId;
    }
    return null;
  }

  /// Devuelve el id del intersticial (iFrame de html), algo parecido
  String getIntersticialAd() {
    if (Platform.isAndroid) {
      const String appId = "ca-app-pub-7462396340145780/8871642021";
      return appId;
    }
    return null;
  }
}
