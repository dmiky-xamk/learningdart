import 'package:flutter/foundation.dart' show immutable;
import 'package:learningdart/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

// ! Output of Bloc -> statet jotka bloc voi palauttaa

// * Itsensä todentamiseen liittyviä stateja mitä sovelluksessa on
// * Tehdään immutable abstract class ilman logiikkaa joista muut perii
@immutable
abstract class AuthState {
  // * Const constructor statelle ja eventeille -> perivät luokat voivat käyttää const constructoria myös
  const AuthState();
}

// * Sovellus ei ole vielä valmis näytettäväksi
class AuthStateUnintialized extends AuthState {
  const AuthStateUnintialized();
}

// ? State should carry with them all the information the UI or the consumer of that bloc
// ? requires in order to fulfill its duty.
class AuthStateSignedIn extends AuthState {
  // * State on kirjauduttu sisään -> state kantaa mukanaan käyttäjän tietoja
  final AuthUser user;

  const AuthStateSignedIn(this.user);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

// * Kirjautuessa tapahtuvat Exceptionit tulevat täältä (jos kirjautuminen epäonnistuu, olet silti kirjautuneena ulos)
class AuthStateSignedOut extends AuthState with EquatableMixin {
  // * Exception joka aiheutti uloskirjautumisen epäonnistumisen
  // * Kirjautuminen epäonnistui -> state kantaa mukanaan epäonnistumisen syytä UI:ta varten
  // * jotta se voi näyttää esim. oikean virheilmoitus
  final Exception? exception;

  // ? FLAG
  // * Kun käyttäjä yrittää kirjautua sisään -> loading true kun tarkistetaan tietoja
  // * "Loading flag built into existing states"
  final bool isLoading;

  const AuthStateSignedOut({
    required this.exception,
    required this.isLoading,
  });

  // * Kun tuotetaan samasta classista useampia stateja, täytyy vertailla instanceja jotta ohjelma tietää päivittää statea
  // * Annetaan propsit, jotka otetaan huomioon vertailussa
  @override
  List<Object?> get props => [exception, isLoading];
}

// * Rekisteröitymässä
class AuthStateRegistering extends AuthState {
  final Exception? exception;

  const AuthStateRegistering(this.exception);
}
