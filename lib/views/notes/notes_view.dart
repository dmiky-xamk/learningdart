// * Pää widget kirjautuneille asiakkaille
import 'package:flutter/material.dart';
import 'package:learningdart/utilities/dialogs/signout_dialog.dart';
import 'package:learningdart/views/notes/notes_list_view.dart';
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

  // * Databasea ei tarvitse sulkea disposen sisällä,
  // * sillä se on singleton ja sen staten pitää pysyä

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Notes"),
          actions: [
            IconButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(createOrUpdateNoteRoute),
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
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          // * Koska stream kuuntelee noteja -> snapshot sisältää kaikki db notet
                          final allNotes = snapshot.data as List<DatabaseNote>;
                          return NotesListView(
                            notes: allNotes,
                            onDeleteNote: (note) async {
                              await _notesService.deleteNote(id: note.id);
                            },
                            onTapNote: (note) {
                              Navigator.of(context).pushNamed(
                                createOrUpdateNoteRoute,
                                arguments: note,
                              );
                            },
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
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
