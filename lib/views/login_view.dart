import 'package:learningdart/constants/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utilities/show_error_dialog.dart';

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

  void handleLoginException(String error) async {
    switch (error) {
      case "user-not-found":
        await showErrorDialog(
          context,
          "User not found",
        );
        break;
      case "wrong-password":
        await showErrorDialog(
          context,
          "Wrong credentials",
        );
        break;
      case "invalid-email":
        await showErrorDialog(
          context,
          "Please enter a valid email",
        );
        break;
      default:
        await showErrorDialog(
          context,
          "Error: $error",
        );
    }
  }

  void loginUser() async {
    final email = _email.text;
    final password = _password.text;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.of(context).pushNamedAndRemoveUntil(
        notesRoute,
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      handleLoginException(e.code);
    } catch (e) {
      handleLoginException(e.toString());
    }
  }

  void navToRegisterView() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      registerRoute,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              onPressed: () => loginUser(), child: const Text("Sign in")),
          TextButton(
              onPressed: navToRegisterView,
              child: const Text("Don't have an account yet? Sign up."))
        ],
      ),
    );
  }
}