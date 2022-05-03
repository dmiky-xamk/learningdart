// ! Input of bloc -> UI:lta tulevia eventejä

import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

// * Tämän pitää kantaa mukanaan kaikkia tietoja, joita Bloc
// * tarvitsee kirjatakseen käyttäjän sisään. (Tiedot tulevat UI:lta)
class AuthEventSignIn extends AuthEvent {
  final String email;
  final String password;

  const AuthEventSignIn(
    this.email,
    this.password,
  );
}

class AuthEventSignOut extends AuthEvent {
  const AuthEventSignOut();
}