// * Pää widget kirjautuneille asiakkaille
import 'package:flutter/material.dart';
import 'package:learningdart/views/services/auth/auth_service.dart';
import 'package:learningdart/views/services/crud/notes_service.dart';

import '../../constants/routes.dart';
import '../../enums/menu_action.dart';

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
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    // * Kutsuu factory constructoria luomaan singletonin
    _notesService = NotesService();
    super.initState();
  }

  @override
  void dispose() {
    // * Suljetaan database
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Notes"),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).pushNamed(newNoteRoute),
              icon: const Icon(Icons.note_add),
            ),
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
        body: FutureBuilder(
          future: _notesService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Text("Waiting for all notes");
                      default:
                        return const CircularProgressIndicator();
                    }
                  },
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
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