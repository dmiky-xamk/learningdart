import 'package:flutter/material.dart';
import 'package:learningdart/utilities/dialogs/delete_dialog.dart';
import 'package:learningdart/views/services/crud/notes_service.dart';

// * Defining a function we are gonna use in this view as a callback,
// * when the user agrees to delete a note.
typedef DeleteNotesCallback = void Function(DatabaseNote note);

// * "Don't leak services everywhere"
// * Tämä widget pystyy delegoimaan noten poistamisen notes_viewille
class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final DeleteNotesCallback onDeleteNote;

  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];

        return ListTile(
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);

              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
