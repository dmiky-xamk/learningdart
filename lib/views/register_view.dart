import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/services/auth/bloc/auth_bloc.dart';
import 'package:learningdart/services/auth/bloc/auth_event.dart';
import 'package:learningdart/services/auth/bloc/auth_state.dart';
import 'package:learningdart/utilities/dialogs/error_dialog.dart';
import 'package:learningdart/services/auth/auth_exceptions.dart';
import 'package:learningdart/services/auth/auth_service.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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

  void showErrorDialogWrapper(String errorMessage) async {
    await showErrorDialog(context, errorMessage);
  }

  void registerUser() async {
    final email = _email.text;
    final password = _password.text;

    context.read<AuthBloc>().add(
          AuthEventRegister(
            email,
            password,
          ),
        );

    // * Lähetetään varmistusta varten sähköposti
    context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
  }

  void navToLoginView() {
    // * Lähetetään käyttäjä kirjautumisnäkymään (käytetään signout eventtiä(?))
    context.read<AuthBloc>().add(
          const AuthEventSignOut(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        // * Varmistutaan että ollaan rekisteröitymässä
        if (state is AuthStateRegistering) {
          // * Mahdollisia virheitä joita voi tulla rekisteröitymisen aikana
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, "Weak password");
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, "Email is already in use");
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, "Invalid email");
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, "Failed to register");
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(title: const Text("Sign up")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Enter your email and password to see your notes!"),
                TextField(
                  autocorrect: false,
                  autofocus: true,
                  controller: _email,
                  decoration: const InputDecoration(hintText: "Email"),
                  enableSuggestions: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  autocorrect: false,
                  controller: _password,
                  decoration: const InputDecoration(hintText: "Password"),
                  enableSuggestions: false,
                  obscureText: true,
                ),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: registerUser,
                          child: const Text("Sign up")),
                      TextButton(
                          onPressed: navToLoginView,
                          child:
                              const Text("Already have an account? Sign in.")),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
