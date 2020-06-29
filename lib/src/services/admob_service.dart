import 'dart:io';

/**
 * Clase que cotrola los id que se usan en la aplicación en la parte de adservice
 */
class AdMobService {

  AdMobService(){}

  String getAdMobAppId(){
    if(Platform.isAndroid){
      const String appId = "ca-app-pub-7462396340145780~9379634838";
      return appId ;
    }
    return null;
  }

  String getBannerHome(){
    if(Platform.isAndroid){
      const String appId = "ca-app-pub-7462396340145780/7300266407";
      return appId ;
    }
    return null;
  }

  String getIntersticialAd(){
    if(Platform.isAndroid){
      const String appId = "ca-app-pub-7462396340145780/8871642021";
      return appId ;
    }
    return null;
  }

  
}