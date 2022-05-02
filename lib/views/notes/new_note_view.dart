import 'package:flutter/material.dart';
import 'package:learningdart/views/services/auth/auth_service.dart';
import 'package:learningdart/views/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({Key? key}) : super(key: key);

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

// * Luodaan uusi note tullessa tähän näkymään.
// * HUOMIO! Hot reload tekisi joka kerta uuden noten tätä tiedostoa muokatessa!
class _NewNoteViewState extends State<NewNoteView> {
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

  Future<DatabaseNote> createNewNote() async {
    // * Tarkistetaan onko tähän näkymään tullessa note luotu jo aiemmin (hot reload tekee joka kerta)
    final existingNote = _note;

    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);

    return await _notesService.createNote(owner: owner);
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
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              // * Saadaan note snapshotista
              _note = snapshot.data as DatabaseNote;

              // * Aletaan kuuntelemaan tekstin muutoksia
              _setupTextControllerListener();

              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                    hintText: "Start typing your note..."),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
