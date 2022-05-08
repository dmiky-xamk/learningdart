import 'package:bloc/bloc.dart';
import 'package:learningdart/services/auth/auth_provider.dart';
import 'package:learningdart/services/auth/bloc/auth_event.dart';
import 'package:learningdart/services/auth/bloc/auth_state.dart';

// ! Ottaa vastaan eventin ja palauttaa staten
// * Luodaan logiikka eventien ja statejen ympärille

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUnintialized(isLoading: true)) {
    // ? Constructorin sisällä handlataan mahdolliset eventit

    // * Initialize (avataan sovellus: ei kirjautunut, sähköpostia ei varmistettu, kirjautunut)
    on<AuthEventInitialize>(
      (_, emit) async {
        await provider.initialize();
        final user = provider.currentUser;

        if (user == null) {
          // * Jos ei käyttäjää -> kirjautunut ulos state -> ei virhettä eikä ladata mitään
          emit(const AuthStateSignedOut(
            exception: null,
            isLoading: false,
          ));
        } else if (!user.isEmailVerified) {
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(AuthStateSignedIn(
            user: user,
            isLoading: false,
          ));
        }
      },
    );

    // * Sign in
    on<AuthEventSignIn>(
      ((event, emit) async {
        // * Vaihdetaan state lataamaan kun yritetään kirjautua sisään
        // emit(const AuthStateUnintialized());
        emit(
          const AuthStateSignedOut(
            exception: null,
            isLoading: true,
            loadingText: "Please wait while you are being signed in",
          ),
        );

        final email = event.email;
        final password = event.password;

        // * Provider pystyy heittämään vain Exceptioneita jotka itse määriteltiin
        try {
          final user = await provider.signIn(
            email: email,
            password: password,
          );

          if (!user.isEmailVerified) {
            emit(
              const AuthStateSignedOut(
                exception: null,
                isLoading: false,
              ),
            );

            emit(const AuthStateNeedsVerification(isLoading: false));
          } else {
            emit(
              const AuthStateSignedOut(
                exception: null,
                isLoading: false,
              ),
            );
            emit(AuthStateSignedIn(
              user: user,
              isLoading: false,
            ));
          }
        } on Exception catch (e) {
          emit(
            AuthStateSignedOut(
              exception: e,
              isLoading: false,
            ),
          );
        }
      }),
    );

    // * Register
    on<AuthEventRegister>(
      (event, emit) async {
        final email = event.email;
        final password = event.password;

        try {
          await provider.signUp(
            email: email,
            password: password,
          );

          await provider.sendEmailVerification();

          // * Uuden käyttäjän luotua state on sähköpostin varmistus
          emit(const AuthStateNeedsVerification(isLoading: false));
        } on Exception catch (e) {
          // * Olet rekisteröitymässä ja jotain pahaa tapahtui
          emit(AuthStateRegistering(
            exception: e,
            isLoading: false,
          ));
        }
      },
    );

    // * Sign out
    on<AuthEventSignOut>(
      (_, emit) async {
        try {
          await provider.signOut();
          emit(
            const AuthStateSignedOut(
              exception: null,
              isLoading: false,
            ),
          );
        } on Exception catch (e) {
          emit(
            AuthStateSignedOut(
              exception: e,
              isLoading: false,
            ),
          );
        }
      },
    );

    // * Send email verification
    on<AuthEventSendEmailVerification>((_, emit) async {
      await provider.sendEmailVerification();

      // * Palautetaan sama state sillä ulkonäkö ei muutu sähköpostin lähetettyä
      emit(state);
    });
  }
}
