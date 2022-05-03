import 'package:flutter/material.dart';
import 'package:learningdart/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:learningdart/utilities/generics/get_arguments.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'package:learningdart/services/cloud/cloud_note.dart';
import 'package:learningdart/services/cloud/cloud_storage_exceptions.dart';
import 'package:learningdart/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

// * Luodaan uusi note tullessa tähän näkymään.
// * HUOMIO! Hot reload tekisi joka kerta uuden noten tätä tiedostoa muokatessa!
class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    // * Singleton -> aina vain yksi instance
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  // * Päivittää noten tekstin muuttuessa
  void _textControllerListener() async {
    final note = _note;

    if (note == null) {
      return;
    }

    final text = _textController.text;
    await _notesService.updateNote(
      documentId: note.documentId,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    // * widgetNote riippuu siitä, tekeekö käyttäjä uuden noten
    // * vai muokkaako käyttäjä jo olemassa olevaa notea
    final widgetNote = context.getArgument<CloudNote>();

    // * Muokataan notea
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    // * Tarkistetaan onko tähän näkymään tullessa note luotu jo aiemmin (hot reload tekee joka kerta)
    final existingNote = _note;

    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;

    return newNote;
  }

  // * Ei ole async sillä poistamisen odottaminen ei hyödytä meitä
  void _deleteNoteIfTextIsEmpty() {
    final note = _note;

    // * Poistetaan note jos teksti on tyhjä poistuessa näkymästä
    if (_textController.text.trim().isEmpty && note != null) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  // * Tallenna nappia ei yleensä ole. Sisältö tallentuu automaattisesti
  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    final text = _textController.text;

    if (note != null && text.trim().isNotEmpty) {
      await _notesService.updateNote(
        documentId: note.documentId,
        text: text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new note"),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_note == null || text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          )
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              // * Aletaan kuuntelemaan tekstin muutoksia
              _setupTextControllerListener();

              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Start typing your note...",
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
