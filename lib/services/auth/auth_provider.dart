import "auth_user.dart";

// ? Luodaan interface jota voidaan käyttää kaikkien kirjautumisvaihtoehtojen kanssa
// * Tämä interface class määrittelee mitä ominaisuuksia käytetään sovelluksen UI tasolla
// * Jokaisesta kirjautumisvaihtoehdosta luodaan oma class, jossa käytetään tämän classin antamia metodeja
// * Esim. Firebasella kirjautumista hallitaan näiden metodien kautta FirebaseAuthProvides -classissa

// * Abstract, protocol, interface
abstract class AuthProvider {
  AuthUser? get currentUser;

  // * Abstract class -> Funktioilla ei bodya

  // * AuthUser ei tarvitse olla nullable, sillä toinen tapa ilmoittaa
  // * kirjautumisen epäonnistumisesta on palauttaa Exception.
  Future<AuthUser> signIn({
    required String email,
    required String password,
  });

  Future<AuthUser> signUp({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendEmailVerification();

  Future<void> initialize();
}
