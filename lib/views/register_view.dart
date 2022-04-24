// * Rekisteröintinäkymä
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';

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

  void registerUser() async {
    final email = _email.text;
    final password = _password.text;

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      print("CREDENTIALS $userCredential");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "weak-password":
          print("Salasana on liian heikko");
          break;
        case "email-already-in-use":
          print("Email is already in use");
          break;
        case "invalid-email":
          print("Sähköposti ei kelpaa");
          break;
        default:
          print("Jokin virhe tapahtui");
          break;
      }
    } catch (e) {
      print("ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Column(
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
                        onPressed: () => registerUser(),
                        child: const Text("Register")),
                  ],
                );
              default:
                return const Text("Loading...");
            }
          }),
    );
  }
}
