import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/services/auth/bloc/auth_event.dart';
import 'package:learningdart/services/auth/bloc/auth_state.dart';
import 'package:learningdart/utilities/dialogs/error_dialog.dart';
import 'package:learningdart/services/auth/auth_exceptions.dart';
import 'package:learningdart/extensions/buildcontext/loc.dart';

import '../services/auth/bloc/auth_bloc.dart';

// * Kirjautumisnäkymä
class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // * Nämä yhdistetään omiin tekstikenttiinsä
  // * Saadaan tuotua kirjoitettu teksti ohjelmaan
  // Samanlainen mitä useState reactissa. Teksti päivittyy aina kun käyttäjä kirjoittaa jotain.
  late final TextEditingController _email;
  late final TextEditingController _password;

  // * Tämä suoritetaan kun HomePage luodaan
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  // * Tämä suoritetaan kun HomePage menee pois muistista
  // ? Muista poistaa luodut controllerit
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> showErrorDialogWrapper(String errorMessage) async {
    await showErrorDialog(
      context,
      errorMessage,
    );
  }

  void signInUser() async {
    final email = _email.text;
    final password = _password.text;

    // * Kerrotaan Blocille -> käyttäjä haluaa kirjautua sisään
    // * Tämän näkymän ei tarvitse tietää sen logiikkaa
    context.read<AuthBloc>().add(
          AuthEventSignIn(
            email,
            password,
          ),
        );
  }

  void navToRegisterView() {
    // * Triggeröidään event
    context.read<AuthBloc>().add(const AuthEventShouldRegister());
  }

  void navToForgotYourPasswordView() {
    context.read<AuthBloc>().add(AuthEventForgotPassword(email: _email.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateSignedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialogWrapper(
                context.loc.login_error_cannot_find_user);
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialogWrapper(
                context.loc.login_error_wrong_credentials);
          } else if (state.exception is GenericAuthException) {
            await showErrorDialogWrapper(context.loc.login_error_auth_error);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
            // title: const Text("Sign in"),
            // title: Text(AppLocalizations.of(context)!.my_title)),
            title: Text(context.loc.login)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                context.loc.login_view_prompt,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: context.loc.email_text_field_placeholder,
                ),
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.emailAddress,
                controller: _email,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: context.loc.password_text_field_placeholder,
                ),
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                controller: _password,
              ),
              TextButton(
                onPressed: signInUser,
                child: Text(context.loc.login),
              ),
              TextButton(
                onPressed: navToRegisterView,
                child: Text(
                  context.loc.login_view_not_registered_yet,
                ),
              ),
              TextButton(
                onPressed: navToForgotYourPasswordView,
                child: Text(
                  context.loc.login_view_forgot_password,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
