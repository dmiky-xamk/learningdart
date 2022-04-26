import 'package:flutter/material.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/views/login_view.dart';
import 'package:learningdart/views/register_view.dart';
import 'package:learningdart/views/services/auth/auth_service.dart';
import 'package:learningdart/views/verify_email_view.dart';
import 'views/notes_view.dart';
import 'dart:developer' as devtools show log;

// * Luodaan stateless HomePage widget
// * Tämä INITIALIZEE Firebasen ja valitsee
// * oikean näkymän riippuen käyttäjän statesta (kirjautunut vai ei)

// * Joissain tapauksissa Firebasen kanssa ennen initializeApp:in suorittamista
// * käyttäjä voi olla null.

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      // * Named routes
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;

            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              // TODO Palauta registerview?
              return const LoginView();
            }

          default:
            // TODO Scaffold tälle? Muuta connectionstate.loading?
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
