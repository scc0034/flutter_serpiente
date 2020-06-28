import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Creamos las instancias de conexión con la base de datos firebase y googlesign
final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
String nameGoogle;
String emailGoogle;
String imageUrlGoogle;

/**
 * Método para conectarnos con Google
 */
Future<String> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  assert(user.email != null);
  assert(user.displayName != null);
  assert(user.photoUrl != null);
  nameGoogle = user.displayName;
  emailGoogle = user.email;
  imageUrlGoogle = user.photoUrl;
  // Only taking the first part of the name, i.e., First Name
  if (nameGoogle.contains(" ")) {
    nameGoogle = nameGoogle.substring(0, nameGoogle.indexOf(" "));
  }

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  return 'signInWithGoogle succeeded: $user';


}

/**
 * Método para salir de la cuenta de Goolge
 */
void signOutGoogle() async{
  await googleSignIn.signOut();

  print("User Sign Out");
}


/**
 * Comando para generar nuevas claves, se debe de ejecutar desde el directorio bin del sdk de java
  * keytool -list -v -keystore "C:\Users\Samuel Casal Cantero\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android 
 
 Exception has occurred.
PlatformException (PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null))
 */

