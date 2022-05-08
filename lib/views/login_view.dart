import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/services/auth/bloc/auth_event.dart';
import 'package:learningdart/services/auth/bloc/auth_state.dart';
import 'package:learningdart/utilities/dialogs/error_dialog.dart';
import 'package:learningdart/utilities/dialogs/loading_dialog.dart';

import '../services/auth/bloc/auth_bloc.dart';
import 'package:learningdart/services/auth/auth_exceptions.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateSignedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialogWrapper("User not found");
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialogWrapper("Wrong credentials");
          } else if (state.exception is GenericAuthException) {
            await showErrorDialogWrapper("Authentication error");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Sign in")),
        body: Column(
          children: [
            TextField(
              decoration: const InputDecoration(hintText: "Email"),
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.emailAddress,
              controller: _email,
            ),
            TextField(
              decoration: const InputDecoration(hintText: "Password"),
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              controller: _password,
            ),
            TextButton(
              onPressed: signInUser,
              child: const Text("Sign in"),
            ),
            TextButton(
              onPressed: navToRegisterView,
              child: const Text("Don't have an account yet? Sign up."),
            )
          ],
        ),
      ),
    );
  }
}
