import "package:firebase_auth/firebase_auth.dart" show User;
import 'package:flutter/cupertino.dart';

// * Class ja subclassit eivät muutu
// TODO Eikö tämä muutu kun käyttäjä varmistaa sähköpostin?
@immutable
class AuthUser {
  final bool isEmailVerified;

  const AuthUser(this.isEmailVerified);

  // * Annetaan meidän classille Firebase user -> luodaan siitä AuthUser joka ottaa email.verified propertyn itselleen
  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}
