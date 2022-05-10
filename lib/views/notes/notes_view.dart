// * Pää widget kirjautuneille asiakkaille
import 'package:flutter/material.dart';
import 'package:learningdart/extensions/buildcontext/loc.dart';
import 'package:learningdart/services/auth/bloc/auth_bloc.dart';
import 'package:learningdart/services/auth/bloc/auth_event.dart';
import 'package:learningdart/services/cloud/cloud_note.dart';
import 'package:learningdart/services/cloud/firebase_cloud_storage.dart';
import 'package:learningdart/utilities/dialogs/signout_dialog.dart';
import 'package:learningdart/views/notes/notes_list_view.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:learningdart/extensions/stream/count.dart';

import '../../constants/routes.dart';
import '../../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

void handleMenuAction(MenuAction action, BuildContext context) async {
  switch (action) {
    case MenuAction.logout:
      // * Dialogi palauttaa joko true tai false
      final shouldSignOut = await showSignOutDialog(context);

      if (shouldSignOut) {
        // * Lähetetään AuthBlocille event -> käyttäjä haluaa kirjautua ulos
        // * Tämän näkymän ei tarvitse huolehtia näkymän vaihtamisesta jos kirjautuminen onnistuu
        context.read<AuthBloc>().add(
              const AuthEventSignOut(),
            );
      }
  }
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    // * Kutsuu factory constructoria luomaan singletonin
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  // * Databasea ei tarvitse sulkea disposen sisällä,
  // * sillä se on singleton ja sen staten pitää pysyä

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<int>(
          stream: _notesService.allNotes(ownerUserId: userId).getLength,
          builder: (context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              final noteCount = snapshot.data ?? 0;
              final text = context.loc.notes_title(noteCount);

              return Text(text);
            } else {
              return const Text("");
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute),
            icon: const Icon(Icons.note_add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) => handleMenuAction(value, context),
            itemBuilder: (context) {
              return [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text(context.loc.logout_button),
                )
              ];
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                // * Koska stream kuuntelee noteja -> snapshot sisältää kaikki db notet
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(documentId: note.documentId);
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
      ),
    );
  }
}
