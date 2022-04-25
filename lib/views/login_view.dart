import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  void loginUser() async {
    final email = _email.text;
    final password = _password.text;

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      print("CREDENTIALS $userCredential");
    } on FirebaseAuthException catch (e) {
      print(e.code);
    } catch (e) {
      print("ERROR TYPE: ${e.runtimeType}");
    }
  }

  void navToRegisterView() {
    Navigator.of(context).pushNamedAndRemoveUntil("/register/", (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
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
          TextButton(onPressed: () => loginUser(), child: const Text("Login")),
          TextButton(
              onPressed: navToRegisterView,
              child: const Text("Don't have an account yet? Sign up."))
        ],
      ),
    );
  }
}
