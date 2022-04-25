import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/views/login_view.dart';
import 'package:learningdart/views/register_view.dart';
import 'package:learningdart/views/verify_email_view.dart';
import 'firebase_options.dart';
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
      routes: {
        "/login/": (context) => const LoginView(),
        "/register/": (context) => const RegisterView()
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;

            if (user != null) {
              if (user.emailVerified) {
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

// * Pää widget kirjautuneille asiakkaille
class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

void testi() {
  devtools.log("Jep");
}

enum MenuAction { logout }

void handleMenuAction(action, context) async {
  switch (action) {
    case MenuAction.logout:
      final shouldSignOut = await showLogOutDialog(context);

      if (shouldSignOut) {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushNamedAndRemoveUntil("/login/", (_) => false);
      }

      return;

    default:
      devtools.log("handleMenuAction: DEFAULT");
  }
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) => handleMenuAction(value, context),
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text("Sign out"),
                )
              ];
            },
          )
        ],
      ),
      body: const Text("Notes"),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Sign out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Sign out"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
        ],
      );
    },
  ).then(
    (value) => value ?? false,
  );
}
