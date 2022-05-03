import 'package:bloc/bloc.dart';
import 'package:learningdart/services/auth/auth_provider.dart';
import 'package:learningdart/services/auth/bloc/auth_event.dart';
import 'package:learningdart/services/auth/bloc/auth_state.dart';

// ! Ottaa vastaan eventin ja palauttaa staten
// * Luodaan logiikka eventien ja statejen ympärille

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    // ? Constructorin sisällä handlataan mahdolliset eventit

    // * Initialize (avataan sovellus: ei kirjautunut, sähköpostia ei varmistettu, kirjautunut)
    on<AuthEventInitialize>(
      (_, emit) async {
        await provider.initialize();
        final user = provider.currentUser;

        if (user == null) {
          emit(const AuthStateSignedOut());
        } else if (!user.isEmailVerified) {
          emit(const AuthStateNeedsVerification());
        } else {
          emit(AuthStateSignedIn(user));
        }
      },
    );

    // * Sign in
    on<AuthEventSignIn>(
      ((event, emit) async {
        // * Vaihdetaan state lataamaan kun yritetään kirjautua sisään
        emit(const AuthStateLoading());

        final email = event.email;
        final password = event.password;

        // * Provider pystyy heittämään vain Exceptioneita jotka itse määriteltiin
        try {
          final user = await provider.signIn(
            email: email,
            password: password,
          );

          emit(AuthStateSignedIn(user));
        } on Exception catch (e) {
          emit(AuthStateSignInFailure(e));
        }
      }),
    );

    // * Sign out
    on<AuthEventSignOut>(
      (_, emit) async {
        try {
          emit(const AuthStateLoading());
          await provider.signOut();

          emit(const AuthStateSignedOut());
        } on Exception catch (e) {
          emit(AuthStateSignOutFailure(e));
        }
      },
    );
  }
}
