import 'package:flutter/foundation.dart' show immutable;
import 'package:learningdart/services/auth/auth_user.dart';

// ! Output of Bloc -> statet jotka bloc voi palauttaa

// * Itsensä todentamiseen liittyviä stateja mitä sovelluksessa on
// * Tehdään immutable abstract class ilman logiikkaa joista muut perii
@immutable
abstract class AuthState {
  // * Const constructor statelle ja eventeille -> perivät luokat voivat käyttää const constructoria myös
  const AuthState();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

// ? State should carry with them all the information the UI or the consumer of that bloc
// ? requires in order to fulfill its duty.
class AuthStateSignedIn extends AuthState {
  // * State on kirjauduttu sisään -> state kantaa mukanaan käyttäjän tietoja
  final AuthUser user;

  const AuthStateSignedIn(this.user);
}

// * Jos kirjautuminen epäonnistuu
class AuthStateSignInFailure extends AuthState {
  // * Exception joka aiheutti kirjautumisen epäonnistumisen
  // * Kirjautuminen epäonnistui -> state kantaa mukanaan epäonnistumisen syytä UI:ta varten
  // * jotta se voi näyttää esim. oikean virheilmoitus
  final Exception exception;

  const AuthStateSignInFailure(this.exception);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateSignedOut extends AuthState {
  const AuthStateSignedOut();
}

class AuthStateSignOutFailure extends AuthState {
  final Exception exception;

  const AuthStateSignOutFailure(this.exception);
}
