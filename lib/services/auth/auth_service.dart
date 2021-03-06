import 'package:learningdart/services/auth/firebase_auth_provider.dart';

import 'auth_provider.dart';
import 'auth_user.dart';

// ! TODO Pitääkö metodien olla async sillä AuthProvider Firebase metodid ovat?

// ? AuthService delegatee toiminnallisuuden sitä käyttävälle providerille
// * It relays the messages of the given auth provider, but can have more logic
// * Exposes the implementation of its provider
class AuthService implements AuthProvider {
  final AuthProvider provider;

  const AuthService(this.provider);

  // * Luodaan factory constructor joka palauttaa aina saman(?) instancen
  // * sillä firebasea joutuu käyttämään useammassa tiedostossa
  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) =>
      provider.signIn(
        email: email,
        password: password,
      );

  @override
  Future<void> signOut() => provider.signOut();

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) =>
      provider.signUp(
        email: email,
        password: password,
      );

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<void> sendPasswordReset({required String toEmail}) =>
      provider.sendPasswordReset(toEmail: toEmail);
}
