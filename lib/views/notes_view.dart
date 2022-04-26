// * Pää widget kirjautuneille asiakkaille
import 'package:flutter/material.dart';
import 'package:learningdart/views/services/auth/auth_service.dart';

import '../constants/routes.dart';
import '../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

void handleMenuAction(action, context) async {
  switch (action) {
    case MenuAction.logout:
      // * Dialogi palauttaa joko true tai false
      final shouldSignOut = await showSignOutDialog(context);

      if (shouldSignOut) {
        await AuthService.firebase().signOut();
        Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false);
      }
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

Future<bool> showSignOutDialog(BuildContext context) {
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
