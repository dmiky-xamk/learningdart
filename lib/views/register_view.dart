import 'package:learningdart/utilities/show_error_dialog.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/views/verify_email_view.dart';

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

  void handleRegisterException(String error) async {
    switch (error) {
      case "weak-password":
        await showErrorDialog(
          context,
          "Try a stronger password",
        );
        break;
      case "email-already-in-use":
        await showErrorDialog(
          context,
          "Email is already in use",
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
        break;
    }
  }

  void registerUser() async {
    final email = _email.text;
    final password = _password.text;

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // * Lähetetään varmistusta varten sähköposti
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

      // * Navigoidaan sähköpostin varmistus näkymään
      Navigator.of(context).pushNamed(verifyEmailRoute);
    } on FirebaseAuthException catch (e) {
      handleRegisterException(e.code);
    } catch (e) {
      handleRegisterException(e.toString());
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
            TextButton(
                onPressed: () => registerUser(), child: const Text("Sign up")),
            TextButton(
                onPressed: navToLoginView,
                child: const Text("Already have an account? Sign in."))
          ],
        ));
  }
}
