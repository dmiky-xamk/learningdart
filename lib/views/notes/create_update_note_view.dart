import 'package:flutter/material.dart';
import 'package:learningdart/utilities/generics/get_arguments.dart';
import 'package:learningdart/views/services/auth/auth_service.dart';
import 'package:learningdart/views/services/crud/notes_service.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

// * Luodaan uusi note tullessa tähän näkymään.
// * HUOMIO! Hot reload tekisi joka kerta uuden noten tätä tiedostoa muokatessa!
class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    // * Singleton -> aina vain yksi instance
    _notesService = NotesService();
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
      note: note,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
    // * widgetNote riippuu siitä, tekeekö käyttäjä uuden noten
    // * vai muokkaako käyttäjä jo olemassa olevaa notea
    final widgetNote = context.getArgument<DatabaseNote>();

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
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;

    return newNote;
  }

  // * Ei ole async sillä poistamisen odottaminen ei hyödytä meitä
  void _deleteNoteIfTextIsEmpty() {
    final note = _note;

    // * Poistetaan note jos teksti on tyhjä poistuessa näkymästä
    if (_textController.text.trim().isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  // * Tallenna nappia ei yleensä ole. Sisältö tallentuu automaattisesti
  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    final text = _textController.text;

    if (note != null && text.trim().isNotEmpty) {
      await _notesService.updateNote(
        note: note,
        text: text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new note"),
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
