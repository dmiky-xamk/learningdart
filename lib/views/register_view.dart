import 'package:learningdart/utilities/show_error_dialog.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/views/services/auth/auth_exceptions.dart';
import 'package:learningdart/views/services/auth/auth_service.dart';

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

    try {
      await AuthService.firebase().signUp(
        email: email,
        password: password,
      );

      // * Lähetetään varmistusta varten sähköposti
      await AuthService.firebase().sendEmailVerification();

      // * Navigoidaan sähköpostin varmistus näkymään
      Navigator.of(context).pushNamed(verifyEmailRoute);
    } on WeakPasswordAuthException {
      showErrorDialogWrapper("Try a stronger password");
    } on EmailAlreadyInUseAuthException {
      showErrorDialogWrapper("Email is already in use");
    } on InvalidEmailAuthException {
      showErrorDialogWrapper("Please enter a valid email");
    } on GenericAuthException {
      showErrorDialogWrapper("Failed to register");
    } catch (e) {
      showErrorDialogWrapper("Tuntematon virhe: ${e.toString()}");
    }
  }

  void navToLoginView() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      loginRoute,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Sign up")),
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
            TextButton(onPressed: registerUser, child: const Text("Sign up")),
            TextButton(
                onPressed: navToLoginView,
                child: const Text("Already have an account? Sign in."))
          ],
        ));
  }
}
