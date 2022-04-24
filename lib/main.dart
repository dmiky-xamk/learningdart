import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/views/login_view.dart';
import 'firebase_options.dart';

// * Luodaan stateless HomePage widget
// * Tämä INITIALIZEE Firebasen ja valitsee
// * oikean näkymän riippuen käyttäjän statesta (kirjautunut vai ei)

// * Joissain tapauksissa Firebasen kanssa ennen initializeApp:in suorittamista
// * käyttäjä voi olla null.

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void checkIsEmailVerified() {
    final user = FirebaseAuth.instance.currentUser;

    if (user?.emailVerified ?? false) {
      print("You are a verified user");
    } else {
      print("Please verify your email");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                checkIsEmailVerified();

                return const Text("Done");
              default:
                return const Text("Loading...");
            }
          }),
    );
  }
}
